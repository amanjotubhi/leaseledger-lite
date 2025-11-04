import { Routes } from '@angular/router';
import { DashboardComponent } from './dashboard/dashboard.component';
import { TenantManagementComponent } from './tenant-management/tenant-management.component';
import { FinancialAnalysisComponent } from './financial-analysis/financial-analysis.component';
import { PropertyAnalyticsComponent } from './property-analytics/property-analytics.component';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'tenants', component: TenantManagementComponent },
  { path: 'financial', component: FinancialAnalysisComponent },
  { path: 'property', component: PropertyAnalyticsComponent },
  { path: '**', redirectTo: '/dashboard' }
];

