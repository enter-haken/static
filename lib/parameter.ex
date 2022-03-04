defmodule Static.Parameter do
  use AbnfParsec,
    abnf_file: "lib/parameter.abnf",
    parse: :params,
    untag: ["params", "action", "word"],
    ignore: [
      "content-path-cmd",
      "output-path-cmd",
      "static-path-cmd",
      "template-cmd",
      "space"
    ]

  alias __MODULE__

  @type t :: %Parameter{
          content_path: String.t(),
          output_path: String.t(),
          static_path: String.t(),
          template: String.t()
        }

  defstruct content_path: nil,
            output_path: nil,
            static_path: nil,
            template: nil

  def get_params(nil), do: []
  def get_params([]), do: []

  def get_params(raw_params) do
    raw_params
    |> Enum.join(" ")
    |> parse()
    |> case do
      {:ok, [parsed_params], _rest, _, _, _} ->
        parsed_params
        |> Enum.reduce(%Parameter{}, fn found_param, acc ->
          case found_param do
            [content_path: [term: [content_path]]] ->
              %Parameter{acc | content_path: content_path |> List.to_string() |> Path.expand()}

            [output_path: [term: [output_path]]] ->
              %Parameter{acc | output_path: output_path |> List.to_string() |> Path.expand()}

            [static_path: [term: [static_path]]] ->
              %Parameter{acc | static_path: static_path |> List.to_string() |> Path.expand()}

            [template: [term: [template]]] ->
              %Parameter{acc | template: template |> List.to_string() |> Path.expand()}

            _ ->
              acc
          end
        end)

      _ ->
        %Parameter{}
    end
  end
end
