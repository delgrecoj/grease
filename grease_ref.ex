defmodule Grease do
  # same thing as the other one just using `ref` atoms, intended for use with `make_ref/0`.

  def set(data, keywordlist) when is_list(data) do
    [fieldpair | [{leadin, fieldpairindex} | rest]] = Enum.reverse(keywordlist)
    args = [ref: fieldpairindex] ++ [fieldpair]
    setfn = rd(setp(args), leadin, rest)
    setfn.(data)
  end

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

  defp rd(prev, :ref, []) when is_function(prev), do: prev

  defp rd(prev, leadin, [{new_leadin, v} | rest])
       when is_function(prev) and is_atom(leadin) and is_atom(new_leadin) and is_list(rest) do
    rd(setp([ref: v] ++ [{leadin, prev}]), new_leadin, rest)
  end
end
