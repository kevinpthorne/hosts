const GATEWAY_DOMAIN = "gateway.kpt.link";
const LEASE_EXPIRY_MS = 15 * 60 * 1000; // 15 minutes (3 missed 5-minute heartbeats)

async function fetchRecords(zoneId, name, apiToken) {
  const url = "https://api.cloudflare.com/client/v4/zones/" + zoneId + "/dns_records?name=" + encodeURIComponent(name) + "&type=A";
  const resp = await fetch(url, {
    headers: {
      "Authorization": "Bearer " + apiToken,
      "Content-Type": "application/json"
    }
  });

  if (!resp.ok) {
    const errText = await resp.text();
    throw new Error("Error fetching records for " + name + ": " + resp.status + " - " + errText);
  }
  const json = await resp.json();
  if (!json.success) {
    throw new Error("Cloudflare error querying " + name + ": " + JSON.stringify(json.errors));
  }
  return json.result || [];
}

async function createRecord(zoneId, name, content, comment, apiToken) {
  const url = "https://api.cloudflare.com/client/v4/zones/" + zoneId + "/dns_records";
  const body = {
    type: "A",
    name: name,
    content: content,
    ttl: 120, // 2 minutes
    proxied: false,
    ...(comment ? { comment: comment } : {})
  };
  const resp = await fetch(url, {
    method: "POST",
    headers: {
      "Authorization": "Bearer " + apiToken,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });
  if (!resp.ok) {
    const errText = await resp.text();
    throw new Error("Error creating record for " + name + ": " + resp.status + " - " + errText);
  }
  return await resp.json();
}

async function updateRecord(zoneId, recordId, name, content, comment, apiToken) {
  const url = "https://api.cloudflare.com/client/v4/zones/" + zoneId + "/dns_records/" + recordId;
  const body = {
    type: "A",
    name: name,
    content: content,
    ttl: 120, // 2 minutes
    proxied: false,
    ...(comment ? { comment: comment } : {})
  };
  const resp = await fetch(url, {
    method: "PUT",
    headers: {
      "Authorization": "Bearer " + apiToken,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  });
  if (!resp.ok) {
    const errText = await resp.text();
    throw new Error("Error updating record " + recordId + ": " + resp.status + " - " + errText);
  }
  return await resp.json();
}

async function deleteRecord(zoneId, recordId, apiToken) {
  const url = "https://api.cloudflare.com/client/v4/zones/" + zoneId + "/dns_records/" + recordId;
  const resp = await fetch(url, {
    method: "DELETE",
    headers: {
      "Authorization": "Bearer " + apiToken,
      "Content-Type": "application/json"
    }
  });
  if (!resp.ok) {
    const errText = await resp.text();
    throw new Error("Error deleting record " + recordId + ": " + resp.status + " - " + errText);
  }
  return await resp.json();
}

async function pruneStaleGatewayRecords(zoneId, gatewayRecords, activeNodeRecordId, now, apiToken) {
  const pruned = [];
  for (const record of gatewayRecords) {
    // Never prune the record currently updated
    if (activeNodeRecordId && record.id === activeNodeRecordId) {
      continue;
    }

    if (record.comment) {
      const match = record.comment.match(/^node:([^|]+)\|ts:(\d+)$/);
      if (match) {
        const nodeName = match[1];
        const recordTs = parseInt(match[2], 10);
        if (now - recordTs > LEASE_EXPIRY_MS) {
          try {
            await deleteRecord(zoneId, record.id, apiToken);
            pruned.push({
              id: record.id,
              node: nodeName,
              expiredAgeSec: Math.round((now - recordTs) / 1000)
            });
          } catch (err) {
            console.error("Failed to prune stale record " + record.id + ":", err);
          }
        }
      }
    }
  }
  return pruned;
}

export default {
  async fetch(request, env) {
    if (request.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }

    const authHeader = request.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return new Response("Unauthorized", { status: 401 });
    }
    const token = authHeader.substring(7);

    // Automatically detect the calling IP using Cloudflare's header
    const clientIp = request.headers.get("CF-Connecting-IP");
    if (!clientIp) {
      return new Response("Could not detect client IP", { status: 400 });
    }

    // Map each VPS's secret token to the specific domain it is allowed to update
    const domainMap = {
      [env.SECRET_ONE_OC]: "one.oc.kpt.link",
      [env.SECRET_TWO_OC]: "two.oc.kpt.link",
      [env.SECRET_THREE_OC]: "three.oc.kpt.link",
    };

    const targetDomain = domainMap[token];
    if (!targetDomain) {
      return new Response("Forbidden or Invalid Token", { status: 403 });
    }

    const zoneId = env.CF_ZONE_ID;
    const apiToken = env.CF_API_TOKEN;

    if (!apiToken) {
      return new Response("Error: CF_API_TOKEN is undefined in the worker environment!", { status: 500 });
    }
    if (!zoneId) {
      return new Response("Error: CF_ZONE_ID is undefined in the worker environment!", { status: 500 });
    }

    const now = Date.now();

    try {
      // 1. Upsert node-specific A record (e.g. one.oc.kpt.link)
      const targetRecords = await fetchRecords(zoneId, targetDomain, apiToken);
      let targetStatus = "unchanged";

      if (targetRecords.length === 0) {
        await createRecord(zoneId, targetDomain, clientIp, null, apiToken);
        targetStatus = "created";
      } else {
        const existingRecord = targetRecords[0];
        if (existingRecord.content !== clientIp) {
          await updateRecord(zoneId, existingRecord.id, targetDomain, clientIp, null, apiToken);
          targetStatus = "updated";
        }
      }

      // 2. Upsert gateway A record (gateway.kpt.link) tagged with this node and current timestamp
      const gatewayRecords = await fetchRecords(zoneId, GATEWAY_DOMAIN, apiToken);
      const nodeTag = "node:" + targetDomain;
      const gatewayComment = nodeTag + "|ts:" + now;

      // Find the record corresponding to this node
      let nodeGatewayRecord = gatewayRecords.find(r => r.comment && r.comment.startsWith(nodeTag));
      if (!nodeGatewayRecord) {
        // Fallback for initial adoption of pre-existing records matching the IP
        nodeGatewayRecord = gatewayRecords.find(r => (!r.comment || !r.comment.startsWith("node:")) && r.content === clientIp);
      }

      let gatewayStatus = "unchanged";
      let activeRecordId = null;

      if (!nodeGatewayRecord) {
        const created = await createRecord(zoneId, GATEWAY_DOMAIN, clientIp, gatewayComment, apiToken);
        gatewayStatus = "created";
        activeRecordId = created.result ? created.result.id : null;
      } else {
        activeRecordId = nodeGatewayRecord.id;
        // Always refresh comment timestamp (lease renewal) or update IP if changed
        if (nodeGatewayRecord.content !== clientIp || nodeGatewayRecord.comment !== gatewayComment) {
          await updateRecord(zoneId, nodeGatewayRecord.id, GATEWAY_DOMAIN, clientIp, gatewayComment, apiToken);
          gatewayStatus = nodeGatewayRecord.content !== clientIp ? "updated" : "lease_refreshed";
        }
      }

      // 3. Prune stale gateway records from nodes that missed heartbeats
      const pruned = await pruneStaleGatewayRecords(zoneId, gatewayRecords, activeRecordId, now, apiToken);

      return new Response(JSON.stringify({
        success: true,
        ip: clientIp,
        node: {
          domain: targetDomain,
          status: targetStatus
        },
        gateway: {
          domain: GATEWAY_DOMAIN,
          status: gatewayStatus
        },
        pruned: pruned
      }), {
        status: 200,
        headers: { "Content-Type": "application/json" }
      });

    } catch (err) {
      return new Response("DDNS Update Error: " + err.message, { status: 500 });
    }
  },

  // Support for optional Cloudflare Worker Cron Trigger to prune dead nodes
  async scheduled(event, env, ctx) {
    const zoneId = env.CF_ZONE_ID;
    const apiToken = env.CF_API_TOKEN;
    if (!zoneId || !apiToken) return;

    try {
      const now = Date.now();
      const gatewayRecords = await fetchRecords(zoneId, GATEWAY_DOMAIN, apiToken);
      await pruneStaleGatewayRecords(zoneId, gatewayRecords, null, now, apiToken);
    } catch (err) {
      console.error("Scheduled pruning error:", err);
    }
  }
};
