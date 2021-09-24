defmodule Piper do
	def to_pipable(value) do
		{:ok, value, []}
	end

	def pipe({:ok, value, _} = input, callable) do
		case callable.(value) do
			{:ok, new_value} -> ok(input, new_value)
			{:error, reason} -> error(input, reason)
		end
	end

	def pipe({:error, _, _} = arg, _), do: arg

	def val({_, v, _}), do: v

	def error(pipeable, message) do
		{:error, elem(pipeable, 1), [message | elem(pipeable, 2)]}
	end

	def ok(pipeable, new_val) do
		{:ok, new_val, elem(pipeable, 2)}
	end
end