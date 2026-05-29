# Rebuilding hyprland-qtutils for the current Qt

`hyprland-qtutils` (and its dep `hyprland-qt-support`) come from the
`solopasha/hyprland` COPR. When Fedora ships a new Qt minor (e.g. 6.10),
the COPR builds can lag — they require the *private* API of the older Qt
they were compiled against, so `dnf install` fails with:

```
package hyprland-qt-support-... requires libQt6Core.so.6(Qt_6.9_PRIVATE_API)
cannot install both qt6-qtbase-6.9.x and qt6-qtbase-6.10.x
```

The fix is to rebuild the COPR's spec files locally against the Qt
that's actually installed.

## Automated

```bash
rebuild-hyprland-qtutils   # bin/executable_rebuild-hyprland-qtutils
```

## Manual steps

```bash
# 1. Download source RPMs from the COPR
dnf download --source hyprland-qt-support hyprland-qtutils

# 2. Install into the rpmbuild tree (also unpacks tarballs + patches)
rpmdev-setuptree   # one-time
rpm -i hyprland-qt-support-*.src.rpm hyprland-qtutils-*.src.rpm

# 3. Install build dependencies
sudo dnf builddep ~/rpmbuild/SPECS/hyprland-qt-support.spec \
                  ~/rpmbuild/SPECS/hyprland-qtutils.spec

# 4. Build (qt-support first — qtutils depends on it)
rpmbuild -ba ~/rpmbuild/SPECS/hyprland-qt-support.spec
rpmbuild -ba ~/rpmbuild/SPECS/hyprland-qtutils.spec

# 5. Install the freshly-built RPMs
sudo dnf install ~/rpmbuild/RPMS/x86_64/hyprland-qt-support-*.rpm \
                 ~/rpmbuild/RPMS/x86_64/hyprland-qtutils-*.rpm
```

After install, the Hyprland "hyprland-qtutils is not installed" startup
warning goes away and `hyprland-dialog` / `hyprland-update-screen` /
`hyprland-donate-screen` are on `$PATH`.

## When to redo this

Each time Fedora ships a new Qt minor before the COPR catches up.
The symptom is the warning returning at login, or `dnf upgrade`
complaining about Qt conflicts pulling in the COPR packages.
