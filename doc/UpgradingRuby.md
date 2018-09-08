# How to upgrade Ruby for this application

This is a step by step guide on how to upgrade a ruby version for this application for both local development as well as running environment.

The whole process requires multiple commits and deployments but allows for a no-downtime and no manual intervention on hosting machines upgrade.
The overall process is as follows:

1. [Add the new ruby version to the infrastructure code](#add-the-new-ruby-version-to-the-infrastructure-code)
2. [Add the new ruby version to the host machines](#add-the-new-ruby-version-to-the-host-machines)
3. [Switch local development to use the new version and ensure everything works](#switch-local-development-to-use-the-new-version-and-ensure-everything-works)
4. [Change the host machines default ruby version for usage](#change-the-host-machines-default-ruby-version-for-usage)
5. [Remove the old ruby version from host machines](#remove-the-old-ruby-version-from-host-machines)
6. [Remove the old ruby version from the infrastructure code](#remove-the-old-ruby-version-from-the-infrastructure-code)

The following subsections will guide you through the whole process.

## Add the new ruby version to the infrastructure code

In the [railsapp/init.pp manifest](../puppet/modules/railsapp/manifests/init.pp), add the desired `rvm_system_ruby` as non default version and corresponding bundler `rvm_gem`. Make sure to name the packages differently than the existing ones (the name is the first string after the package declaration, in the following example 'ruby-2.5.1' or 'bundler251'). For example, in the `if $rvm_installed == true {` conditional block, after the existing ruby version, add:

```diff
+    rvm_system_ruby { 'ruby-2.5.1':
+        name        => 'ruby-2.5.1',
+        ensure      => 'present',
+        build_opts  => '--disable-binary',
+        default_use => false
+    }
+
+    rvm_gem { 'bundler251':
+        name         => 'bundler',
+        ruby_version => 'ruby-2.5.1@global',
+        ensure       => '1.16.4',
+        require      => Rvm_system_ruby['ruby-2.5.1'];
+    }
```

Make a commit and push.

## Add the new ruby version to the host machines

After making sure the commit made in the previous step is in whichever branch you're using to deploy to your environment, deploy it to all your environments. Note that the puppet step will take significantly longer than previous builds upong doing so as puppet will be downloading, compiling and installing the new ruby version.

If you encounter any errors or failures, the most likely scenario is that the new ruby version requires some new native library to be present in the host to be successfully installed. If that is the case, make sure you add it in the [init.pp manifest](../puppet/modules/railsapp/manifests/init.pp) and add a `require` condition to the `rvm_system_ruby` (like you see in the `rvm_gem`).

Once your deployment is successful, your host machines should list the new ruby version as available through rvm but your application won't be yet using it.

## Switch the local development to use the new version and ensure everything works

You can do so by changing the [Gemfile](../Gemfile) to indicate the ruby version desired. This would mean switching `ruby '2.4.3'` for `ruby '2.5.1'`.
With that done, you can run `bundle install` and `bundle exec rake ci`. If you're using rvm with autoruby load, after making the Gemfile change, you will need to `cd` out of the directory and back in before running `bundle install`.

Once your tests are passing locally (make whichever changes you need to), make sure to update the [.travis.yml file](../.travis.yml) and the [circle config file](../.circleci/config.yml) to reflect the new ruby version and, if you're using another CI tool, you might have to manually change the ruby version used for building this project.

Once all of that is happy, make a new commit. Don't push to your auto-deploy branch (or don't trigger a deploy) just yet.

## Change the host machines default ruby version for usage

In the [init.pp file](../puppet/modules/railsapp/manifests/init.pp), change the default ruby to match the new desired version. That means in the old version, where is used to say `default_use => true`, change it to `default_use => false` and, in the new version, to the opposite.

```diff
     rvm_system_ruby { 'ruby-2.4.3':
         name        => 'ruby-2.4.3',
         ensure      => 'present',
         build_opts  => '--disable-binary',
-        default_use => true
+        default_use => false
     }

     rvm_gem { 'bundler243':
         name         => 'bundler',
         ruby_version => 'ruby-2.4.3@global',
         ensure       => '1.16.0',
         require      => Rvm_system_ruby['ruby-2.4.3'];
     }

     rvm_system_ruby { 'ruby-2.5.1':
         name        => 'ruby-2.5.1',
         ensure      => 'present',
         build_opts  => '--disable-binary',
-        default_use => false
+        default_use => true
     }

     rvm_gem { 'bundler251':
         name         => 'bundler',
         ruby_version => 'ruby-2.5.1@global',
         ensure       => '1.16.4',
         require      => Rvm_system_ruby['ruby-2.5.1'];
     }
```

Then on the [passenger.pp file](../puppet/modules/railsapp/manifests/passenger.pp), change the `rvm::passenger::apache` class to use the desired ruby version. For example:

```diff
 if $rvm_installed == true {
   class { 'rvm::passenger::apache':
       version            => '5.0.23',
-      ruby_version       => 'ruby-2.4.3',
+      ruby_version       => 'ruby-2.5.1',
       mininstances       => '3',
       maxinstancesperapp => '0',
       maxpoolsize        => '30',
       spawnmethod        => 'smart-lv2',
       notify => Class['apache::service'],
   }
 }
```

With those changes, make a commit and push to master (or deploy your branch).

The deployment process should then restart passenger using the previously installed ruby version and use it by default for any non-passenger processes that might run.

Your application should now be running using the new version of ruby you've upgraded to.

## Remove the old ruby version from host machines

Once you're happy that your application is working well in the new version, it's time to clean up the hosts from old ruby versions to reduce disk usage and avoid potential issues/conflicts.

To do so, simply change the [init.pp manifest](../puppet/modules/railsapp/manifests/init.pp) so that the old version of ruby is marked as `ensure      => 'absent'` (no need to remove the bundler gem as the ruby uninstall will remove the gem as well) such as:

```diff
     rvm_system_ruby { 'ruby-2.4.3':
         name        => 'ruby-2.4.3',
-        ensure      => 'present',
+        ensure      => 'absent',
         build_opts  => '--disable-binary',
         default_use => false
     }
```

Make a commit, push and deploy. This should remove the ruby version from rvm therefore clearing out some disk space on your hosts.

## Remove the old ruby version from the infrastructure code

Now that the old version is no longer used for anything and isn't present on the hosts anymore, you can finally get rid of it from the repo.
Simply remove all traces of it from the [init.pp manifest](../puppet/modules/railsapp/manifests/init.pp) like this:

```diff
-    rvm_system_ruby { 'ruby-2.4.3':
-        name        => 'ruby-2.4.3',
-        ensure      => 'present',
-        build_opts  => '--disable-binary',
-        default_use => false
-    }
-
-    rvm_gem { 'bundler243':
-        name         => 'bundler',
-        ruby_version => 'ruby-2.4.3@global',
-        ensure       => '1.16.0',
-        require      => Rvm_system_ruby['ruby-2.4.3'];
-    }
```

Done. You've successfully upgraded the ruby version of this application.
