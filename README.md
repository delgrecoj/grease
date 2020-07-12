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

```elixir
jobs = [
  %{id: 0, ops: [
    %{id: 0, specs: [
      %{id: 0, comments: [
        %{id: 0, text: "asdf"}
      ]}
    ]}
  ]}
]

Enum.map(jobs, fn job ->
  if job.id == 0 do
    %{
      job
      | ops:
          Enum.map(job.ops, fn op ->
            if op.id == 0 do
              %{
                op
                | specs:
                    Enum.map(op.specs, fn spec ->
                      if spec.id == 0 do
                        %{
                          spec
                          | comments:
                              Enum.map(spec.comments, fn comment ->
                                if comment.id == 0 do
                                  %{comment | text: "qwerty"}
                                else
                                  comment
                                end
                              end)
                        }
                      else
                        spec
                      end
                    end)
              }
            else
              op
            end
          end)
    }
  else
    job
  end
end)
```

This repository is just some helpers to make that easier and less error-prone;

```elixir
Grease.set(views, id: 0, count: &(&1 + 1))
Grease.set(jobs, id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty")
```

Note that `Grease.set/2` assumes there are `:id` fields at each level; you'll have to design your data structures around
that, but those `:id` fields needn't be any particular type beyond something that behaves well with `==`, nor need they
be the same type, i.e. you can have one level use integer ids and another use `make_ref()` ids.

