class User < ActiveRecord::Base
	has_and_belongs_to_many :groups

	
  def group?(group_name)
  	group = Group.find_by_sql("select * from users u, groups_users gu, groups g 
  		where u.id = gu.user_id and g.id = gu.group_id and u.id = '#{self.id}' and g.name = '#{group_name}'")
  	if !group.blank?
  		return true
  	else 
  		return false
  	end
  end

	def add_group(group_name)
    unless group_name.nil?
      if ((self.group?(group_name)) == false)
        group = Group.find_by_name(group_name)
        if !group.blank?
        	group.users << self
        	notice = "The user has been successfully added to the group."
        end
       else
       	 notice = "The user is already part of the group."
      end
    end
    return notice
  end
  
  def remove_group(group_name)
    unless group_name.nil?
      if self.group?(group_name)
      	g = Group.find_by_name(group_name)
        self.groups.delete(g)
        notice = "The user has been successfully removed from the group."
      end
    end
    return notice
  end

end
