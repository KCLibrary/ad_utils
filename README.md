# AdUtils

Some simple utilities for creating users and "reservations" in ActiveDirectory.

Because ActiveDirectory logon hours are setup on a weekly basis, reservations have to be scheduled rather than directly set. This gem uses DelayedJob to schedule these actions, but could easily be extended to use another background processing system.

Add to `Gemfile` like:

    gem 'ad_utils', git: 'https://github.com/kardeiz/ad_utils'

and `bundle`.

Somewhere in your application do:

    AdUtils.config do |conf|
      conf.connection = hash
      # where hash is a standard Net::LDAP initialization hash
      conf.base_groups = arr
      # where arr is an array of Group DNs that you would like to add new users to
    end

Then you can add a user like:

    user = AdUtils::User.new({
      uid:        'kardeiz',
      last_name:  'Brown',
      first_name: 'Jacob',
      password:   'test'
    })

    user.create
    user.delete

You can create a reservation (i.e., add logon hours for a specified datetime), like so:

    res = AdUtils::Reservation.new({
      uid:        user.uid,
      start_time: Time.now.beginning_of_hour,
      end_time:   Time.now.beginning_of_hour + 3.hours
    })

    res.create