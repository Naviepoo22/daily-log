# daily-log

One commit per day, pushed from a Linux VM by a systemd timer. No dependencies beyond
`git`, `ssh`, and `systemd`.

## Setup on the VM (Oracle Cloud, Ubuntu/Oracle Linux)

1. Make a dedicated SSH key (no passphrase, so the timer can use it unattended):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/daily_log -N "" -C daily-log
   cat ~/.ssh/daily_log.pub
   ```

2. On GitHub: repo **Settings → Deploy keys → Add deploy key**, paste the public key,
   tick **Allow write access**. The key can only touch this one repo.

3. Trust GitHub's host key (compare against GitHub's published fingerprints:
   <https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints>):

   ```bash
   ssh-keyscan github.com >> ~/.ssh/known_hosts
   ```

4. Clone with that key and set your commit identity. The email **must** be one verified
   on your GitHub account (or your `ID+username@users.noreply.github.com`), otherwise
   commits push fine but no green square appears.

   ```bash
   git clone -c core.sshCommand="ssh -i ~/.ssh/daily_log -o IdentitiesOnly=yes" \
     git@github.com:YOUR_USER/daily-log.git ~/daily-log
   cd ~/daily-log
   git config user.name  "Your Name"
   git config user.email "you@example.com"
   ```

5. Test once by hand, then install the timer:

   ```bash
   ./commit.sh
   ./install.sh 09:00
   ```

## Operating it

```bash
systemctl list-timers daily-log.timer     # next run
journalctl -u daily-log.service -n 20     # last run's output
sudo systemctl start daily-log.service    # run now
./install.sh 21:30                        # change time
./install.sh --uninstall                  # stop
```

The time is in the VM's timezone (`timedatectl`; Oracle Cloud images default to UTC).

## Green-square rules

- Commits only count on the **default branch** of a **non-fork** repo.
- If the repo is **private**, enable **Profile → Contributions → Include private
  contributions** or the squares won't show.
