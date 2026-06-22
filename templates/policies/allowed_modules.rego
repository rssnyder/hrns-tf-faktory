package terraform_plan

################################################################################
# 1. Collect every module-call source string (set, no duplicates)
################################################################################
module_calls[call] {
  walk(input.configuration.root_module, [p, v])
  p[count(p)-1] == "module_calls"            # node *is* a module_calls map
  mc := v[_]                                 # one module_call object
  call := mc                          			 # its call
}

################################################################################
# 3. Policy – deny when a source is **neither** "../…" **nor** app.harness.io/…
################################################################################
deny[msg] {
  call := module_calls[_]

  not startswith(call.source, "../")                  				# ignore local "../" modules
  not startswith(call.source, "./")                   				# ignore local "./" modules
  not startswith(call.source, "app.harness.io/")      				# allow modules from harness account
  not startswith(call.source, "terraform-aws-modules/")             # allow offical modules from aws

  msg := sprintf(
    "Module source %q is not allowed (must start with ../, ./, app.harness.io/, or terraform-aws-modules/)",
    [call.source],
  )
}

################################################################################
# 4. Policy – require specific version of a module
################################################################################
deny[msg] {
	allowed_versions := ["2.2.0", "2.3.0"]

  call := module_calls[_]

  call.source == "terraform-aws-modules/kms/aws"

  not contains(allowed_versions, call.version_constraint)

  msg := sprintf(
    "Module %s version %s is not allowed, must be one of: %s",
    [call.source, call.version_constraint, allowed_versions],
  )
}

################################################################################
# 5. Policy – deny when a resources are provisioned outside a module
################################################################################
deny[msg] {
	allowed_types := ["aws_cloudwatch_log_group"]

	r = input.planned_values.root_module.resources[_]

	not contains(allowed_types, r.type)

  msg := sprintf(
    "Resource of type %s is not allowed outside a module",
    [r.type],
  )
}

contains(arr, elem) {
	arr[_] = elem
}