require IEx;

defmodule Grease do

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

  # intention here is to smooth over the same problem Sugar.set/2 does,
  # except provide slightly cleaner syntax when id fields can be assumed.

  def set(data, keywordlist) do
    [fieldpair | [{leadin, fieldpairindex} | rest]] = Enum.reverse(keywordlist)
    args = [id: fieldpairindex] ++ [fieldpair]
    setfn = rd(Grease.set(args), leadin, rest)
    setfn.(data)
  end

  # recursively deconstructs the keyword list into nested fncalls
  defp rd(prev, :id, []), do: prev
  defp rd(prev, leadin, [{new_leadin, v} | rest]) do
    rd(Grease.set([id: v] ++ [{leadin, prev}]), new_leadin, rest)
  end

end

defmodule GreaseExamples do
  def set() do
    jobs = [
      %{id: 0, ops: [
        %{id: 0, specs: [
          %{id: 0, comments: [
            %{id: 0, text: "asdf"}
          ]}
        ]}
      ]}
    ]

    # change "asdf" above to "qwerty", assuming id fields throughout.
    Grease.set(jobs, [id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty"])
    Grease.set(jobs, id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty")
    jobs |> Grease.set(id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty")
    jobs |> Grease.set id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty"
    # Grease.set(jobs, id: 0, ops:
    #   Grease.set(id: 0, specs:
    #     Grease.set(id: 0, comments:
    #       Grease.set(id: 0, text: "qwerty"))))
  end
end
