defmodule Grease do

  # duplicate of Sugar.set/1
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

  # duplicate of Sugar.set/2
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

  # intention here is to smooth over the same problem Sugar.set/2 does,
  # except provide slightly cleaner syntax when id fields can be assumed.

  def set(data, keywordlist) when is_list(data) do
    [fieldpair | [{leadin, fieldpairindex} | rest]] = Enum.reverse(keywordlist)
    args = [id: fieldpairindex] ++ [fieldpair]
    setfn = rd(Grease.set(args), leadin, rest)
    setfn.(data)
  end

  # recursively deconstructs the keyword list into nested fncalls
  defp rd(prev, :id, []) when is_function(prev), do: prev
  defp rd(prev, leadin, [{new_leadin, v} | rest]) when is_function(prev) and is_atom(leadin) and is_atom(new_leadin) and is_list(rest) do
    rd(Grease.set([id: v] ++ [{leadin, prev}]), new_leadin, rest)
  end

end

defmodule GreaseExamples do
  def very_nested_set() do
    jobs = [
      %{id: 0, ops: [
        %{id: 0, specs: [
          %{id: 0, comments: [
            %{id: 0, text: "asdf"}
          ]}
        ]}
      ]}
    ]

    # various ways of calling:
    Grease.set(jobs, [id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty"])
    Grease.set(jobs, id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty")
    jobs |> Grease.set(id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty")

    jobs
    |> IO.inspect([label: "before"])
    |> Grease.set(id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty")
    |> IO.inspect([label: "after"])
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

    data
    |> IO.inspect([label: "before"])
    |> Grease.set(id: 3, count: 60)
    |> IO.inspect([label: "after"])
  end
end
