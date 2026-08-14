# Code comments

Be sparse when adding comments. Do not add unnecessary comments.

A comment earns its place by explaining **why**, not restating **what** the code
already says. If deleting it would lose no information, don't write it.

Keep a comment to one sentence wherever it will fit — wrapping that sentence over
two lines is fine, adding a second sentence usually isn't. Spend more only on
something genuinely subtle — a crash whose cause isn't visible from the code, a
trap someone would otherwise walk back into — and even then, cut it to the
shortest version that still saves the reader that debugging session.

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

Don't preface a why-comment with a sentence restating the code it sits above —
start at the reason. A block that earns its length still doesn't earn an opener
that summarises the function, script, or assignment underneath it.

Also skip comments that restate a function signature, section-divider banners,
and notes about the change itself ("added this to fix X") — that belongs in the
commit message.
