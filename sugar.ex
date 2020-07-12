defmodule Sugar do

  # often have data that follows this format:
  # [
  #   %{id: 0, val: "asdf"},
  #   %{id: 1, val: "querty"},
  #   %{id: 2, val: "mnbvc"},
  # ]
  # then need to update a particular field of a particular item in the list.
  # thus often have Enum.map..fn..if/else blocks everywhere.
  # these are messy and error-prone; easy to miss an else case and lose data.

  def set(data, [{keyf, keyv}, {valf, valv}])
      when is_atom(keyf) and is_atom(valf) and is_list(data) do
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

  # generally try to use separate pools for sublists but when not doing that,
  # it gets worse the more levels of nesting you've got in the maps.
  # jobs = [
  #   %{id: 0, ops: []},
  #   %{id: 1, ops: [
  #     %{id: 0, desc: "poiuyt"},
  #     %{id: 1, desc: "rtyui"},
  #   ]},
  #   %{id: 2, ops: [
  #     %{id: 0, desc: "asdf"},
  #     %{id: 1, desc: "querty"},
  #   ]},
  # ]

  def set([{keyf, keyv}, {valf, valv}]) when is_atom(keyf) and is_atom(valf) do
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

end

defmodule SugarExamples do
  def set() do
    data = [
      %{id: 0, count: 0},
      %{id: 1, count: 0},
      %{id: 2, count: 0},
      %{id: 3, count: 0},
      %{id: 4, count: 0}
    ]

    Sugar.set(data, id: 3, count: 60)

    # same as the following:
    # Enum.map(data, fn m ->
    #   if m.id == 3 do
    #     %{m | count: 60}
    #   else
    #     m
    #   end
    # end)
  end

  def nested_set() do
    jobs = [
      %{
        id: 0,
        ops: [
          %{id: 0, desc: "asdf"},
          %{id: 1, desc: "fdsa"}
        ]
      },
      %{
        id: 1,
        ops: [
          %{id: 0, desc: "asdf"},
          %{id: 1, desc: "fdsa"}
        ]
      },
      %{
        id: 2,
        ops: [
          %{id: 0, desc: "asdf"},
          %{id: 1, desc: "fdsa"}
        ]
      }
    ]

    Sugar.set(jobs, id: 1, ops: Sugar.set(id: 1, desc: "qwerty"))

    # same as the following:
    # Enum.map(data, fn m ->
    #   if m.id == 1 do
    #     %{m | ops: Enum.map(m.ops, fn op ->
    #       if op.id == 1 do
    #         %{op | desc: "qwerty"}
    #       else
    #         op
    #       end
    #     end)}
    #   else
    #     m
    #   end
    # end)
  end

  def set_with_fn() do
    data = [
      %{id: 0, count: 0},
      %{id: 1, count: 0},
      %{id: 2, count: 0},
      %{id: 3, count: 0},
      %{id: 4, count: 0}
    ]

    # arbitrary functions can be thrown in as well.
    Sugar.set(data, id: 3, count: &(&1 + 1))

    # do not necessarily have to use the short syntax; this is identical.
    Sugar.set(data, id: 3, count: fn count -> count + 1 end)

    # same as the following:
    # Enum.map(data, fn m ->
    #   if m.id == 3 do
    #     %{m | count: m.count + 1}
    #   else
    #     m
    #   end
    # end)
  end

  def set_with_arbitrary_nesting() do
    jobs = [
      %{
        id: 0,
        ops: [
          %{
            id: 0,
            subops: [
              %{
                id: 0,
                micromanaged: [
                  %{id: 0, desc: "asdf"}
                ]
              }
            ]
          }
        ]
      }
    ]

    Sugar.set(jobs,
      id: 0,
      ops:
        Sugar.set(id: 0, subops: Sugar.set(id: 0, micromanaged: Sugar.set(id: 0, desc: "qwerty")))
    )
  end
end
