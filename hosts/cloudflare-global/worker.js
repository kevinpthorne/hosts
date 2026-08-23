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

    // First, we need to GET the DNS record ID for the targetDomain.
    const getRecordsUrl = "https://api.cloudflare.com/client/v4/zones/" + zoneId + "/dns_records?name=" + targetDomain + "&type=A";
    const getResp = await fetch(getRecordsUrl, {
      headers: {
        "Authorization": "Bearer " + apiToken,
        "Content-Type": "application/json"
      }
    });

    if (!getResp.ok) {
      const errText = await getResp.text();
      return new Response("Error fetching record from Cloudflare: " + getResp.status + " - " + errText, { status: 500 });
    }
    const getJson = await getResp.json();

    if (!getJson.success || getJson.result.length === 0) {
      // Create the record if it doesn't exist
      const createResp = await fetch("https://api.cloudflare.com/client/v4/zones/" + zoneId + "/dns_records", {
        method: "POST",
        headers: {
          "Authorization": "Bearer " + apiToken,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          type: "A",
          name: targetDomain,
          content: clientIp,
          ttl: 120, // 2 minutes
          proxied: false
        })
      });
      return new Response(await createResp.text(), { status: createResp.status });
    } else {
      // Update existing record
      const recordId = getJson.result[0].id;
      // Skip update if IP hasn't changed
      if (getJson.result[0].content === clientIp) {
        return new Response(JSON.stringify({ success: true, message: "IP unchanged", ip: clientIp }), { 
          status: 200, 
          headers: { "Content-Type": "application/json"} 
        });
      }

      const updateResp = await fetch("https://api.cloudflare.com/client/v4/zones/" + zoneId + "/dns_records/" + recordId, {
        method: "PUT",
        headers: {
          "Authorization": "Bearer " + apiToken,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          type: "A",
          name: targetDomain,
          content: clientIp,
          ttl: 120,
          proxied: false
        })
      });
      return new Response(await updateResp.text(), { status: updateResp.status });
    }
  }
};
