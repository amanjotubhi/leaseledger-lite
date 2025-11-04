import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DataService } from '../data.service';

@Component({
  selector: 'app-tenant-management',
  imports: [CommonModule],
  templateUrl: './tenant-management.component.html',
  styleUrl: './tenant-management.component.scss'
})
export class TenantManagementComponent implements OnInit {
  analysis: any = null;
  loading = false;
  
  constructor(private dataService: DataService) {}
  
  ngOnInit() {
    this.loadData();
  }
  
  loadData() {
    // Check for cached data first - instant display
    const cached = this.dataService.tenantAnalysisSubject.value;
    if (cached) {
      this.analysis = cached;
      this.loading = false;
    } else {
      this.loading = true;
    }
    
    // Subscribe to updates (will get cached or new data)
    this.dataService.getTenantAnalysis().subscribe({
      next: (data) => {
        if (data) {
          this.analysis = data;
          this.loading = false;
        }
      }
    });
  }
  
  formatCurrency(value: number): string {
    return '$' + value.toFixed(2);
  }
  
  getRiskLevel(count: number, total: number): string {
    const percentage = (count / total * 100);
    if (percentage > 20) return 'high';
    if (percentage > 10) return 'medium';
    return 'low';
  }
  
  parseFloat(value: string): number {
    return parseFloat(value?.replace('$', '') || '0');
  }
}

