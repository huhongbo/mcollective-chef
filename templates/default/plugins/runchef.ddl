metadata    :name        => "run chef echo",
		    :description => "run info agent output",
        	:author      => "dn365",
	        :license     => "GPLv2",
            :version     => "0.1",
            :url         => "https://github.com/dn365/mcollective-chef",
            :timeout     => 300

action "echo", :description => "puts echo" do
	display :always
	
	input :msg,
		  :prompt => "puts echo",
		  :description => "puts echo",
		  :type => :string,
		  :validation => '^.+$',
		  :optional => false,
		  :maxlength => 60
	output :msg,
		   :description => "cmd outpus info",
           :display_as => "output"
end
action "chefrun", :description => "chef client run" do
	display :always
	
	output :stdout,
        :description => "Standard output from the chef-client init script",
        :display_as => "stdout"

    output :stderr,
        :description => "Error output from the chef-client init script",
        :display_as => "stderr"

    output :output,
        :description => "The exit code set by the chef-client init script after running the action.",
        :display_as => "exitcode"
end