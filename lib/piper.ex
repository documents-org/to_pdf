defmodule Piper do
	def to_pipable(value) do
		{:pipable, :ok, value, []}
	end

	def pipe({:pipable, :ok, value, _} = input, callable) do
		case callable.(value) do
			{:ok, new_value} -> ok(input, new_value)
			{:error, reason} -> error(input, reason)
		end
	end

	def pipe({:pipable, :error, _, _} = arg, _), do: arg

	def val({:pipable, _, v, _}), do: v

	def error(pipeable, message) do
		{:pipable, :error, elem(pipeable, 2), [message | elem(pipeable, 3)]}
	end

	def ok(pipeable, new_val) do
		{:pipable, :ok, new_val, elem(pipeable, 3)}
	end

	def ok?({:pipable, state, _, _}), do: state == :ok
	def errored?({:pipable, state, _, _}), do: state == :error
	def errors({:pipable, _, _, errors}), do: errors
end