defmodule ParameterTest do
  use ExUnit.Case

  alias Static.Parameter

  describe "It is expected to get an empty Parameter struct for" do
    test "nil" do
      assert Parameter.get_params(nil) == %Parameter{}
    end

    test "an empty list" do
      assert Parameter.get_params([]) == %Parameter{}
    end
  end

  describe "It is expected to get" do
    test "a content path" do
      %Parameter{
        content_path: absolute_content_path
      } = Parameter.get_params(["--content-path", "test_path"])

      assert absolute_content_path == "test_path" |> Path.expand()
    end

    test "an output path" do
      %Parameter{
        output_path: absolute_output_path
      } = Parameter.get_params(["--output-path", "test_path"])

      assert absolute_output_path == "test_path" |> Path.expand()
    end

    test "an static path" do
      %Parameter{
        static_path: absolute_static_path
      } = Parameter.get_params(["--static-path", "test_path"])

      assert absolute_static_path == "test_path" |> Path.expand()
    end

    test "a template" do
      %Parameter{
        template: absoulte_template_path
      } = Parameter.get_params(["--template", "template.eex"])

      assert absoulte_template_path == "template.eex" |> Path.expand()
    end
    
    test "unknown parameter" do
      assert %Parameter{
      } == Parameter.get_params(["--tempte"])
    end
 
     test "incomplete parameter" do
      assert %Parameter{
      } == Parameter.get_params(["--template"])
    end
  end
end
