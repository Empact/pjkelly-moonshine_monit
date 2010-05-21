module Monit

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:monit => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :monit
  #  recipe :monit
  def monit(options = {})
    package 'monit', :ensure => :installed

    file '/etc/monit/monitrc', 
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'monitrc'), binding), 
      :mode => '600',
      :owner => configuration[:user],
      :group => configuration[:group] || configuration[:user],
      :require => package('monit'),
      :before => service('monit'),
      :notify => service('monit')

    file '/etc/monit.d', 
      :ensure => :directory,
      :mode   => 644,
      :owner => configuration[:user],
      :group => configuration[:group] || configuration[:user],
      :before => service("monit")

    file '/etc/monit.d/apache', 
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'apache'), binding), 
      :mode => '600',
      :owner => configuration[:user],
      :group => configuration[:group] || configuration[:user],
      :require => file('/etc/monit.d')

    file '/etc/default/monit', 
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'startup')), 
      :mode => '644',
      :owner => configuration[:user],
      :group => configuration[:group] || configuration[:user],
      :before => service("monit")

    file '/etc/init.d/monit',
      :mode => '755',
      :owner => configuration[:user],
      :group => configuration[:group] || configuration[:user],
      :before => service("monit")

    service 'monit', 
      :require => package('monit'),
      :enable => true, 
      :ensure => :running,
      :hasstatus => true
  end

end
