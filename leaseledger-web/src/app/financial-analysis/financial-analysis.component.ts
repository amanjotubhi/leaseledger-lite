import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DataService } from '../data.service';

@Component({
  selector: 'app-financial-analysis',
  imports: [CommonModule],
  templateUrl: './financial-analysis.component.html',
  styleUrl: './financial-analysis.component.scss'
})
export class FinancialAnalysisComponent implements OnInit {
  insights: any = null;
  loading = false;
  
  constructor(private dataService: DataService) {}
  
  ngOnInit() {
    this.loadData();
  }
  
  loadData() {
    // Check for cached data first - instant display
    const cached = this.dataService.financialInsightsSubject.value;
    if (cached) {
      this.insights = cached;
      this.loading = false;
    } else {
      this.loading = true;
    }
    
    // Subscribe to updates (will get cached or new data)
    this.dataService.getFinancialInsights().subscribe({
      next: (data) => {
        if (data) {
          this.insights = data;
          this.loading = false;
        }
      }
    });
  }
  
  formatCurrency(value: number): string {
    return '$' + value.toFixed(2);
  }
  
  getCollectionRateClass(rate: number): string {
    if (rate >= 95) return 'excellent';
    if (rate >= 85) return 'good';
    if (rate >= 75) return 'fair';
    return 'poor';
  }
}

