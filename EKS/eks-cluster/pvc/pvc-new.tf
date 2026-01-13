# PVC for AWS EKS using EBS CSI Driver

resource "kubernetes_storage_class" "ebs_csi" {
  metadata {
    name = "ebs-sc"
  }

  storage_provisioner = "ebs.csi.aws.com"

  parameters = {
    type = "gp3"
    fsType = "ext4"
  }

  volume_binding_mode = "WaitForFirstConsumer"

}

# PVC for that StorageClass

resource "kubernetes_persistent_volume_claim" "ebs_pvc" {

    metadata {
      name = "ebs-claim"
    }

    spec {

      access_modes = ["ReadWriteOnce"]
      storage_class_name = kubernetes_storage_class.ebs_csi.metadata[0].name

      resources {

        requests = {
            storage = "10Gi"
        }

      }

    }

}
