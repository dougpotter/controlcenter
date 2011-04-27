# Copied from http://lslezak.blogspot.com/2009/06/renaming-rake-task.html

# add rename_task method to Rake::Application
# it has an internal hash with name -> Rake::Task mapping
module Rake
  class Application
    def rename_task(task, oldname, newname)
      if @tasks.nil?
        @tasks = {}
      end

      @tasks[newname.to_s] = task

      if @tasks.has_key? oldname
        @tasks.delete oldname
      end
    end
  end
end

# add new rename method to Rake::Task class
# to rename a task
class Rake::Task
  def rename(new_name)
    if !new_name.nil?
      old_name = @name

      if old_name == new_name
        return
      end

      @name = new_name.to_s
      application.rename_task(self, old_name, new_name)
    end
  end
end

# shortcut in global namespace, just like rake's task method
def rename_task(old_name, new_name)
  Rake::Task[old_name].rename(new_name)
end
