# Parser

A markdown parser you can use to persist checkboxes.

## Setup your Project

- Ensure the port is `5432` and the password is the same as the configuration.
- $ `mix setup`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
- Visit: http://localhost:4000

## Valid Input

```
### Solar System Exploration, 1950s – 1960s

- [ ] Mercury
- [x] Venus
- [x] Earth (Orbit/Moon)
- [x] Mars
- [ ] Jupiter
- [ ] Saturn
- [ ] Uranus
- [ ] Neptune
- [ ] Comet Haley
```

## Invalid Input

```
<pre><code>
1 & 2
1 > 2
</code></pre>
```
