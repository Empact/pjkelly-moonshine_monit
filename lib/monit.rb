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

    options = {}.merge!(options)

    file '/etc/monit/monitrc', 
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'monitrc'), binding), 
      :mode => '600',
      :require => package('monit')

    file '/etc/monit.d', :ensure => :directory, :require => package('monit')
    file '/etc/monit.d/apache', 
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'apache'), binding), 
      :mode => '600',
      :require => file('/etc/monit.d')

    file '/etc/default/monit', 
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'startup')), 
      :mode => '644',
      :require => package('monit')

    file '/etc/init.d/monit',
      :mode => '755',
      :require => package('monit')

    service 'monit', 
      :require => [
        file('/etc/monit/monitrc'),
        file('/etc/init.d/monit'),
        file('/etc/default/monit')
      ], 
      :enable => true, 
      :ensure => :running
  end
  
end