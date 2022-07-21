Dreamkast API
=============

## How to use Dreamkast API with JWT Auth

### Retrieve CLIENT ID and CLIENT SECRET from Auth0

https://manage.auth0.com/dashboard/us/dreamkast/applications/Piz0aBnXn0vxesyZScc76PgdCB7lCAbk/settings

### Generate JWT Token

```
AUTH0_DOMAIN=dreamkast.us.auth0.com
CLIENT_ID=<CLIENT ID>
CLIENT_SECRET=<CLIENT SECRET>
AUDIENCE=https://event.cloudnativedays.jp/
TOKEN=$(curl --url https://${AUTH0_DOMAIN}/oauth/token \
  --header 'content-type: application/json' \
  --data "{\"client_id\":\"${CLIENT_ID}\",\"client_secret\":\"${CLIENT_SECRET}\",\"audience\":\"${AUDIENCE}\",\"grant_type\":\"client_credentials\"}" | jq -r .access_token)
DREAMKAST_DOMAIN='event.cloudnativedays.jp'
```

※ Don't retrieve JWT token frequently due to Auth0 limitation. We recommend store generated token into environment variable. Generated token is available 1 day.

### Use API with Bearer token

```
curl -X GET -H "Authorization: Bearer $TOKEN" https://$DREAMKAST_DOMAIN/api/v1/foobar
```


## VideoRegistration API

### Get VideoRegistration

```
curl -X GET -H "Authorization: Bearer $TOKEN" https://$DREAMKAST_DOMAIN/api/v1/talks/1/video_registration
```

### Set URL

```
curl -X PUT -H "Authorization: Bearer $TOKEN" https://$DREAMKAST_DOMAIN/api/v1/talks/1/video_registration -d '{
  "url": "https://foobar"
}'
```

### Set video status

You can set these values in status.

- unsubmitted
- submitted
- confirmed
- invalid_format

```
curl -X PUT -H "Authorization: Bearer $TOKEN" https://$DREAMKAST_DOMAIN/api/v1/talks/1/video_registration -d '{
  "status": "confirmed",
  "statistics": {
            "file_name": "XX",
            "resolution_status": "OK",
            "resolution_type": "FHD",
            "aspect_status": "OK",
            "aspect_ratio": "16:9",
            "duration_status": "OK",
            "duration_description": "Appropriate media duration.",
            "size_status": "OK",
            "size_description": "Appropriate media size."
          }
}'
```

## Switch on_air status

```
curl -X PUT -H "Authorization: Bearer $TOKEN" https://$DREAMKAST_DOMAIN/api/v1/talks/{talkId} -d '{
  "on_air": true
}'
```
