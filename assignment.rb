# Sentia - assigment.rb - Milen Petrov 2016-06-20

# get command options
require 'getoptlong'

instances = 1
instance_type = ''
allow_ssh_from = ''

begin
  opts = GetoptLong.new(
    ['--instances', GetoptLong::OPTIONAL_ARGUMENT],
    ['--instance-type', GetoptLong::OPTIONAL_ARGUMENT],
    ['--allow-ssh-from', GetoptLong::OPTIONAL_ARGUMENT]
  )
  opts.quiet = true
  opts.each do |opt, arg|
    case opt
    when '--instances'
      instances = arg
    when '--instance-type'
      instance_type = arg
    when '--allow-ssh-from'
      allow_ssh_from = arg
    end
  end
rescue => e
  puts
  puts "Error: #{e}"
end

# read EC2 template
ec2_instance_template = ''
begin
  ec2_instance_template = File.read('ec2_instance_template.json')
rescue => e
  puts
  puts "Error: #{e}"
  exit 1
end

# parse EC2 template
require 'json'

ec2_instance = {}
begin
  ec2_instance = JSON.parse(ec2_instance_template)
rescue => e
  puts
  puts "Error: #{e}"
  exit 1
end

# modify EC2 instance(s)
unless instance_type == ''
  ec2_instance['Resources']\
              ['EC2Instance']\
              ['Properties']\
              ['InstanceType'] = instance_type
end

instance_security_group = ec2_instance['Resources']['InstanceSecurityGroup']
ec2_instance['Resources'].delete('InstanceSecurityGroup')

(instances.to_i - 1).times do |i|
  ec2_instance['Resources']\
              ["EC2Instance#{i + 2}"] = ec2_instance['Resources']\
                                                    ['EC2Instance']
end

unless allow_ssh_from == ''
  instance_security_group['Properties']\
                         ['SecurityGroupIngress']\
                         [0]\
                         ['CidrIp'] = allow_ssh_from + '/32'
end
ec2_instance['Resources']\
            ['InstanceSecurityGroup'] = instance_security_group

# output
puts JSON.pretty_generate(ec2_instance)

# Finished
