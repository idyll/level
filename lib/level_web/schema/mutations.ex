defmodule LevelWeb.Schema.Mutations do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc "A validation error."
  object :error do
    @desc "The name of the invalid attribute."
    field :attribute, non_null(:string)

    @desc "A human-friendly error message."
    field :message, non_null(:string)
  end

  @desc "The response to inviting a user to a space."
  object :invite_user_payload do
    @desc """
    A boolean indicating if the mutation was successful. If true, the errors
    list will be empty. Otherwise, errors may contain objects describing why
    the mutation failed.
    """
    field :success, :boolean

    @desc "A list of validation errors."
    field :errors, list_of(:error)

    @desc """
    The newly-created object. If the mutation was not successful,
    this field will be null.
    """
    field :invitation, :invitation
  end

  @desc "The response to revoking an invitation."
  object :revoke_invitation_payload do
    @desc """
    A boolean indicating if the mutation was successful. If true, the errors
    list will be empty. Otherwise, errors may contain objects describing why
    the mutation failed.
    """
    field :success, :boolean

    @desc "A list of validation errors."
    field :errors, list_of(:error)

    @desc """
    The mutated object. If the mutation was not successful,
    this field may be null.
    """
    field :invitation, :invitation
  end

  @desc "The response to creating a group."
  object :create_group_payload do
    @desc """
    A boolean indicating if the mutation was successful. If true, the errors
    list will be empty. Otherwise, errors may contain objects describing why
    the mutation failed.
    """
    field :success, :boolean

    @desc "A list of validation errors."
    field :errors, list_of(:error)

    @desc """
    The mutated object. If the mutation was not successful,
    this field may be null.
    """
    field :group, :group
  end

  @desc "The response to updating a group."
  object :update_group_payload do
    @desc """
    A boolean indicating if the mutation was successful. If true, the errors
    list will be empty. Otherwise, errors may contain objects describing why
    the mutation failed.
    """
    field :success, :boolean

    @desc "A list of validation errors."
    field :errors, list_of(:error)

    @desc """
    The mutated object. If the mutation was not successful,
    this field may be null.
    """
    field :group, :group
  end
end
