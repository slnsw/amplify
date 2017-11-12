# Transcript Tool: Setting up authentication methods

The Transcript Tool supports practically any authentication method that has an
Omniauth connector available. Internally it uses the `devise_token_auth` gem,
which works with Omniauth to provide token-based authentication, allowing the
authentication to work independently of the user interface.

## Supported authentication providers

* Google OAuth2
* Facebook
* SAML
  * Works against Azure AD

Considering implementing:

* Gigya

## Connecting auth providers to project

In your `project.json` file, look for an `authProviders` parameter and add each
auth provider you want to that array. For example, here's the relevant snippet
that implements Google OAuth2 and Facebook:

```json
{
  "authProviders": [
    {
      "name": "google",
      "label": "Google",
      "path": "/auth/google_oauth2"
    },
    {
      "name": "facebook",
      "label": "Facebook",
      "path": "/auth/facebook"
    }
  ]
}
```

Parameters:

* `name` - internal ID for auth provider
* `label` - how the auth provider is displayed on the frontend
* `path` - the path to the auth provider - the part after `/auth/` directly  
  maps to the standard `omniauth` path parameter.

After updating your `project.json` file, always run
`rake project:load['my-project']` to refresh this config in the user interface.

## Providers

### Google OAuth2

1. Log in to your Google account and visit  
   [https://console.developers.google.com/](https://console.developers.google.com/).  
   Complete any registration steps required.
2. Once you are logged into your Developer dashboard,  
   [create a project](https://console.developers.google.com/project).
3. In your project's dashboard click *enable and manage Google APIs*.  
   You must enable at least *Contacts API* and *Google+ API*
4. Click the *Credentials* tab of your project dashboard, *Create credentials*  
   for an *OAuth client ID* and select *Web application*.
5. You should make at least two credentials for your Development and  
   Production environments. You can also create one for a Test environment.
6. For development, enter `http://localhost:3000` (or whatever your  
   development URI is) for your *Authorized Javascript origins* and  
   `http://localhost:3000/omniauth/google_oauth2/callback` for your  
   *Authorized redirect URIs*.
7. For production, enter the same values, but replace `http://localhost:3000`  
   with your production URI e.g. `https://myproject.com`.
8. Open up your `config/application.yml`.
9. For each development and production, copy the values listed for *Client ID*  
   and *Client secret* into the appropriate key-value entry. For example:
   ```
   development:
     GOOGLE_CLIENT_ID: 1234567890-abcdefghijklmnop.apps.googleusercontent.com
     GOOGLE_CLIENT_SECRET: aAbBcCdDeEfFgGhHiIjKlLmM
   production:
     GOOGLE_CLIENT_ID: 0987654321-ghijklmnopabcdef.apps.googleusercontent.com
     GOOGLE_CLIENT_SECRET: gGhHiIjKlLmMaAbBcCdDeEfF
  ```

### Facebook

1. Log in to your Facebook account and visit  
   [this link](https://developers.facebook.com/quickstarts/?platform=web).
2. Follow the steps to create a new app and go to the app's Dashboard.  
   You must at least fill out **Display Name** and **Contact Email**.
3. In your project's dashboard click *Add Product* on the left panel.  
   Then click *Facebook Login*.
4. Under *Client OAuth Settings*:
   - make sure *Client OAuth Login* and *Web OAuth Login* is on
   - enter `http://localhost:3000/omniauth/facebook/callback` in  
     *Valid OAuth redirect URIs*. Also include your production or testing 
     URLs here too (e.g. `http://myapp.com/omniauth/facebook/callback`).
   - Save your changes
5. On the left panel, select *Test Apps*. Click *Create a Test App* and  
   go to its dashboard after you create it.
6. Note these two values: *App ID* and *App Secret*
7. Open up your `config/application.yml`
8. For each development and production, copy the values listed for *App ID*  
   and *App Secret* into the appropriate key-value entry, e.g.
   ```
   development:
     FACEBOOK_APP_ID: "1234567890123456"
     FACEBOOK_APP_SECRET: abcdefghijklmnopqrstuvwxyz123456
   production:
     FACEBOOK_APP_ID: "7890123456123456"
     FACEBOOK_APP_SECRET: nopqrstuvwxyz123456abcdefghijklm
  ```

### SAML

1. Set up your SAML app depending on how your identity provider wants you
   to do it.
2. Download the certificate file and copy it to `config/certificates`.
3. For each development and production app, copy the configuration into the
   appropriate key-value entries. For example:
   ```
   development:
     SAML_CONSUMER_SERVICE_URL: https://my.dev.app/omniauth/saml/callback
     SAML_ISSUER: dev-issuer-id
     SAML_SSO_TARGET_URL: https://my.dev.service/path/to/saml/service
     SAML_IDP_CERT_PATH: config/certificates/my-dev-cert-file
     SAML_NAME_ID_FORMAT: urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress
   production:
     SAML_CONSUMER_SERVICE_URL: https://my.prod.app/omniauth/saml/callback
     SAML_ISSUER: prod-issuer-id
     SAML_SSO_TARGET_URL: https://my.prod.service/path/to/saml/service
     SAML_IDP_CERT_PATH: config/certificates/my-prod-cert-file
     SAML_NAME_ID_FORMAT: urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress
   ```
