Parametrization.configure do

  # Configuration directives in this file are translated into shortcut methods in your controllers.
  # Here are several examples of configuration directives and the methods they would set up:
  #
  #   attributes_for :user, [ :first_name, :last_name, :email, :phone, :dob, :password ]  ----> `user_params`
  #
  #   attributes_for user: [ :first_name, :last_name, :email, :phone, :dob, :password ]   ----> `user_params`
  #
  #   attributes_for :user do
  #     default   :email, :phone, :password                                               ----> `user_params`
  #     create    :email, :first_name, :last_name, :phone, :dob, :password                ----> `user_params_for_create`
  #     update    :phone, :dob, :password                                                 ----> `user_params_for_update`
  #     anything  :first_name, :last_name, :dob, :password                                ----> `user_params_for_anything`
  #   end
  #
  # Note that specifying the `default` situation is equivalent to specifying those attributes via
  # the simple syntax.
  #
  # If you want to use nested attributes, do something like this:
  #
  #   attributes_for :address do
  #     default   :city, :state, :zip, :latitude, :longitude
  #     update    :city, :state, :zip
  #   end
  #   attributes_for :user do
  #     default   :first_name, :last_name, addresses_attributes: :address
  #     update    :first_name, :last_name, addresses_attributes: :address_for_update
  #   end
  #
  # The configuration will automatically convert the :address and :address_for_update symbols into the
  # same arrays that are used for `address_params` and `address_params_for_update` respectively. This
  # will work even if the reference points to a set of attributes defined later in the file.





end
