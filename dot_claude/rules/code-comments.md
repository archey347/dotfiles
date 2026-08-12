# Code comments

Be sparse when adding comments. Do not add unnecessary comments.

A comment earns its place by explaining **why**, not restating **what** the code
already says. If deleting it would lose no information, don't write it.

Bad — narrates what the code plainly shows, including the fact that defaults are
being relied on:

```puppet
# The module's defaults are already the values we want, so there is nothing to
# pass but the path and rotation count.
logrotate::rule { 'app':
  path   => '/var/log/app/*.log',
  rotate => 7,
}
```

Good — the code says what, the comment says why it is needed:

```yaml
# Nightly batch imports briefly exceed the default upload cap
app::uploads::max_size_mb: 512
```

Also skip comments that restate a function signature, section-divider banners,
and notes about the change itself ("added this to fix X") — that belongs in the
commit message.
