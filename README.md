# Grease

Often in Elixir you'll have lists of maps;

```elixir
views = [
  %{id: 0, count: 0},
  %{id: 1, count: 0},
  %{id: 2, count: 0},
  %{id: 3, count: 0},
  %{id: 4, count: 0}
]
```

Then you often need to update a field on a particular entry;

```elixir
Enum.map(views, fn v ->
  if v.id == 2 do
    %{v | count: v.count + 1}
  else
    v
  end
end)
```

Not terrible, but easy to not include the else case and lose data;

```elixir
Enum.map(views, fn v ->
  if v.id == 2 do
    %{v | count: v.count + 1}
  end
end)
```

Moreover, it scales very poorly with nested data structures;

> FIXME: need to mess with xmodmap to get grave key working...

This repository is just some helpers to make that easier and less error-prone;

> FIXME: need to mess with xmodmap to get grave key working...

