locals {
  // Standard tags applied to all managed resources
  required_tags = {
    created_by : "Terraform"
  }

  common_tags = merge(local.required_tags, var.tags)

  // Convert tags from map to list format (Harness API requirement)
  common_tags_tuple = [for k, v in local.common_tags : "${k}:${v}"]

  // Kubernetes infrastructure configuration for pipeline execution stages
  k8s_setup = {
    KUBERNETES_CONNECTOR : var.kubernetes_connector
    KUBERNETES_NAMESPACE : var.kubernetes_namespace
    KUBERNETES_SERVICEACCOUNT : (var.kubernetes_serviceaccount != "skipped" ? var.kubernetes_serviceaccount : "skipped")
    KUBERNETES_OVERRIDE_RUNAS : (var.kubernetes_override_run_as_user != "skipped" ? tonumber(var.kubernetes_override_run_as_user) : "skipped")
    KUBERNETES_NODESELECTORS : (
      length(var.kubernetes_node_selectors) == 0
      ?
      "skipped"
      :
      yamlencode(var.kubernetes_node_selectors)
    )
    KUBERNETES_IMAGE_CONNECTOR : var.kubernetes_override_image_connector
  }

  // Pipeline infrastructure template for IACM stages
  IACM_STAGE_INFRASTRUCTURE = templatefile(
    "${path.module}/templates/snippets/iacm_infrastructure.yaml",
    local.k8s_setup
  )

  // Pipeline infrastructure template for IDP stages
  IDP_STAGE_INFRASTRUCTURE = templatefile(
    "${path.module}/templates/snippets/idp_infrastructure.yaml",
    local.k8s_setup
  )

  // TF step template
  TF_STEP = templatefile(
    "${path.module}/templates/snippets/tf_step.yaml",
    {
      PROVISIONER_TYPE : var.provisioner_type == "terraform" ? "IACMTerraformPlugin" : "IACMOpenTofuPlugin"
      PLUGIN_IMAGE : var.plugin_image
      PLUGIN_CONNECTOR : var.plugin_connector
    }
  )
}
