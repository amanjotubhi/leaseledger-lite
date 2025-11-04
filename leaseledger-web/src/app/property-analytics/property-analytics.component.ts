import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DataService } from '../data.service';

@Component({
  selector: 'app-property-analytics',
  imports: [CommonModule],
  templateUrl: './property-analytics.component.html',
  styleUrl: './property-analytics.component.scss'
})
export class PropertyAnalyticsComponent implements OnInit {
  metrics: any = null;
  loading = false;
  
  constructor(private dataService: DataService) {}
  
  ngOnInit() {
    this.loadData();
  }
  
  loadData() {
    // Check for cached data first - instant display
    const cached = this.dataService.propertyMetricsSubject.value;
    if (cached) {
      this.metrics = cached;
      this.loading = false;
    } else {
      this.loading = true;
    }
    
    // Subscribe to updates (will get cached or new data)
    this.dataService.getPropertyMetrics().subscribe({
      next: (data) => {
        if (data) {
          this.metrics = data;
          this.loading = false;
        }
      }
    });
  }
  
  formatCurrency(value: number): string {
    return '$' + value.toFixed(2);
  }
  
  getOccupancyClass(rate: number): string {
    if (rate >= 90) return 'excellent';
    if (rate >= 75) return 'good';
    return 'needs-improvement';
  }
}

