defmodule Grease do
  # helper function for improving ergonomics of updating nested maps in lists,
  # provided id atom fields can be assumed to exist; see GreaseExamples for usage.
  def set(data, keywordlist) when is_list(data) do
    [fieldpair | [{leadin, fieldpairindex} | rest]] = Enum.reverse(keywordlist)
    args = [id: fieldpairindex] ++ [fieldpair]
    setfn = rd(setp(args), leadin, rest)
    setfn.(data)
  end

  # generate function for updating particular field using literal or function
  defp setp([{keyf, keyv}, {valf, valv}]) when is_atom(keyf) and is_atom(valf) do
    fn data ->
      Enum.map(data, fn map ->
        if map[keyf] == keyv do
          if is_function(valv) do
            Map.update!(map, valf, valv)
          else
            Map.update!(map, valf, fn _ -> valv end)
          end
        else
          map
        end
      end)
    end
  end

  # base-case for recursively deconstructing the keyword list
  defp rd(prev, :id, []) when is_function(prev), do: prev

  # recursively deconstructs the keyword list into nested fncalls
  defp rd(prev, leadin, [{new_leadin, v} | rest])
       when is_function(prev) and is_atom(leadin) and is_atom(new_leadin) and is_list(rest) do
    rd(setp([id: v] ++ [{leadin, prev}]), new_leadin, rest)
  end
end

defmodule GreaseExamples do
  def very_nested_set() do
    jobs = [
      %{
        id: 0,
        ops: [
          %{
            id: 0,
            specs: [
              %{
                id: 0,
                comments: [
                  %{id: 0, text: "asdf"}
                ]
              }
            ]
          }
        ]
      }
    ]

    Grease.set(jobs, id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty")

    # various other ways of calling:
    # Grease.set(jobs, [id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty"])
    # jobs |> Grease.set(id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty")

    # same as the following:
    # Enum.map(jobs, fn job ->
    #   if job.id == 0 do
    #     %{
    #       job
    #       | ops:
    #           Enum.map(job.ops, fn op ->
    #             if op.id == 0 do
    #               %{
    #                 op
    #                 | specs:
    #                     Enum.map(op.specs, fn spec ->
    #                       if spec.id == 0 do
    #                         %{
    #                           spec
    #                           | comments:
    #                               Enum.map(spec.comments, fn comment ->
    #                                 if comment.id == 0 do
    #                                   %{comment | text: "qwerty"}
    #                                 else
    #                                   comment
    #                                 end
    #                               end)
    #                         }
    #                       else
    #                         spec
    #                       end
    #                     end)
    #               }
    #             else
    #               op
    #             end
    #           end)
    #     }
    #   else
    #     job
    #   end
    # end)
  end

  def simple_set() do
    data = [
      %{id: 0, count: 0},
      %{id: 1, count: 0},
      %{id: 2, count: 0},
      %{id: 3, count: 0},
      %{id: 4, count: 0}
    ]

    Grease.set(data, id: 3, count: 60)

    # same as the following:
    # Enum.map(data, fn m ->
    #   if m.id == 3 do
    #     %{m | count: 60}
    #   else
    #     m
    #   end
    # end)
  end

  def set_using_fn() do
    data = [
      %{id: 0, count: 0},
      %{id: 1, count: 0},
      %{id: 2, count: 0},
      %{id: 3, count: 0},
      %{id: 4, count: 0}
    ]

    # none of this prevents applying functions instead of literals;
    data
    |> Grease.set(id: 3, count: &(&1 + 1))
    |> Grease.set(id: 3, count: &(&1 + 42))
    |> Grease.set(id: 3, count: fn c -> c + 3 end)
  end
end
