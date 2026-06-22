package pipeline

# Deny IACM stages without any template
deny[msg] {
    stage := input.pipeline.stages[i].stage
    stage.type == "IACM"
    not stage.template
    msg := sprintf("IaCM stage '%s' must use a template", [stage.name])
}

# Deny IACM stages with template not at account level
deny[msg] {
    stage := input.pipeline.stages[i].stage
    stage.type == "IACM"
    stage.template
    not startswith(stage.template.templateRef, "account.")
    msg := sprintf("IaCM stage '%s' does not use an account level template", [stage.name])
}
