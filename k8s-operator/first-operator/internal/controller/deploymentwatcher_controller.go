/*
Copyright 2025 Sushil Bhile.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controller

import (
	"context"
	"fmt"

	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	"example.com/api/v1beta1"
	spektrav1beta1 "example.com/api/v1beta1"
)

// DeploymentWatcherReconciler reconciles a DeploymentWatcher object
type DeploymentWatcherReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

// +kubebuilder:rbac:groups=spektra.example.com,resources=deploymentwatchers,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=spektra.example.com,resources=deploymentwatchers/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=spektra.example.com,resources=deploymentwatchers/finalizers,verbs=update

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the DeploymentWatcher object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.19.0/pkg/reconcile
func (r *DeploymentWatcherReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	_ = log.FromContext(ctx)

	deploymentWatcher := &v1beta1.DeploymentWatcher{}

	err := r.Get(ctx, req.NamespacedName, deploymentWatcher, &client.GetOptions{})
	if err != nil {
		panic("some error occured")
	} else {
		fmt.Println("This is the object", deploymentWatcher)
	}
	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *DeploymentWatcherReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&spektrav1beta1.DeploymentWatcher{}).
		Complete(r)
}
