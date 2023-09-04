# Services and background tasks

## Puma

This application uses Puma to run the webserver. It doesn't play particularly
nicely with systemd, but we have a few options about how we want to
initialise the application at server boot time.

We have a sample init.d script here:
[amplify-init-example.sh](../config/amplify-init-example.sh)

To set this up, copy it to `/etc/init.d/amplify`, customise it as necessary,
make it executable `chmod a+x /etc/init.d/amplify` and run
`update-rc.d /etc/init.d/amplify defaults` to ensures it runs at boot time.

There's also a sample puma systemd unit, but it probably needs refinement:
[puma.service](../config/puma.service)

## Sidekiq

This application uses Sidekiq to manage background tasks. We recommend you use
systemd to run Sidekiq in your staging and production environments.
The commands provided by capistrano-sidekiq will generate a systemd service
file for you, but if you're using RVM to manage your rubies, change the
`ExecStart` command to wrap it in `/bin/bash -lc`.

We have a sample systemd unit file that works with RVM here:
[sidekiq-env.service](./examples/sidekiq-env.service)

You'll want to add your file to `~/.config/systemd/user`, and then
symlink it to `~/.config/systemd/user/default.user.wants/sidekiq-yourenv.service`.

For more info, take a look at [sidekiq's sample systemd unit file](https://github.com/mperham/sidekiq/blob/master/examples/systemd/sidekiq.service).

## Troubleshooting

### Failed to connect to bus

When running `systemctl --user` as your deploy user,
you might see a message along the lines of:

```text
Failed to connect to bus: No such file or directory
```

This is usually a sign that systemd hasn't been set up for your user right.

As the root user, ensure that your deploy user is using `/bin/bash` as
their login shell. Use the `chsh` command to change it if necessary.

As the root user, run `loginctl enable-linger <name-of-deploy-user>` to enable
services that persist when a login session is not running.

Finally, add the following (verbatim) to your user's `.bashrc` file:

```bash
export XDG_RUNTIME_DIR="/run/user/$UID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
```

Log out and log back in as your deploy user so your changes can take effect.

For more info:

* https://www.freedesktop.org/software/systemd/man/loginctl.html
* https://gist.github.com/Cretezy/dc64ed4519c63c3eb636fba354f93a1f