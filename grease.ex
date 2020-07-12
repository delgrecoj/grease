defmodule Grease do

  # intention here is to smooth over the same problem Sugar.set/2 does,
  # except provide slightly cleaner syntax when id fields can be assumed.

  def set(data, keywordlist) do
    # FIXME
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
      ]},
      %{id: 1, ops: [
        %{id: 0, specs: [
          %{id: 0, comments: [
            %{id: 0, text: "zxcv"}
          ]}
        ]}
      ]}
    ]

    # change "asdf" above to "qwerty", assuming id fields throughout.
    Grease.set(jobs, [id: 0, ops: 0, specs: 0, comments: 0, text: "qwerty"])
  end
end
