#API

## Get chat sessionId & token (TBD)

####Request:

	GET /api/chat?name=Mike

####Response:

	{
		"sessionId"="2_MX40NDYzMjU2MX5-VGh1IEphbiAzMCAwNzoyOTo1OCBQU1QgMjAxNH4wLjMwMzY1OTAyfg",
		"token"="T1==cGFydG5lcl9pZD00...",
		"agentName": "Amy"
	}

The `name` query parameter will identify the user and it will be displayed in the agent's web view. Once a client has connected to a session they should be able to query metadata about who is present. For now however, we'll fake it by using this `agentName` porperty.

## Restart the session

####Request:

	GET /api/restart

####Response:

	OK

In the hackathon universe, there is only one session, one agent and one user. Call this API to restart the single session.

## Upload screenshot

####Request:

	POST /api/screenshot
    Content-type: multipart/form-data;

    name="source"
    ...

####Response:

	OK

Upload screenshots to this endpoint for mirroring.
