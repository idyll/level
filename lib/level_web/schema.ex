defmodule LevelWeb.Schema do
  @moduledoc false

  use Absinthe.Schema
  import_types(LevelWeb.Schema.Types)

  alias Level.Repo

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(:db, Dataloader.Ecto.new(Repo))

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  query do
    @desc "The currently authenticated user."
    field :viewer, :user do
      resolve(fn _, %{context: %{current_user: current_user}} ->
        {:ok, current_user}
      end)
    end
  end

  mutation do
    @desc "Invite a person to a space via email."
    field :invite_user, type: :invite_user_payload do
      arg(:email, non_null(:string))

      resolve(&Level.Mutations.create_invitation/2)
    end

    @desc "Revoke an invitation."
    field :revoke_invitation, type: :revoke_invitation_payload do
      arg(:id, non_null(:id))

      resolve(&Level.Mutations.revoke_invitation/2)
    end

    @desc "Create a group."
    field :create_group, type: :create_group_payload do
      arg(:name, non_null(:string))
      arg(:description, :string)
      arg(:is_private, :boolean)

      resolve(&Level.Mutations.create_group/2)
    end

    @desc "Update a group."
    field :update_group, type: :update_group_payload do
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:description, :string)
      arg(:is_private, :boolean)

      resolve(&Level.Mutations.update_group/2)
    end
  end
end
