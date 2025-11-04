import { Component, OnInit, AfterViewInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DataService } from '../data.service';

@Component({
  selector: 'app-dashboard',
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss'
})
export class DashboardComponent implements OnInit, AfterViewInit {
  rent: any[] = [];
  aging: any[] = [];
  loading = false;
  refreshing = false;
  dataLoaded = false;
  
  // Summary metrics
  totalCharges = 0;
  totalPayments = 0;
  totalBalance = 0;
  totalAging = 0;
  overdueCount = 0;
  
  // Animation states
  cardsVisible = false;
  tablesVisible = false;
  
  constructor(private dataService: DataService) {}
  
  ngOnInit() {
    this.loadData();
  }
  
  ngAfterViewInit() {
    setTimeout(() => {
      this.cardsVisible = true;
      setTimeout(() => {
        this.tablesVisible = true;
      }, 200);
    }, 100);
  }
  
  loadData() {
    // Check for cached data first - instant display
    const cachedRent = this.dataService.rentRollSubject.value;
    const cachedAging = this.dataService.agingSubject.value;
    
    if (cachedRent.length > 0) {
      this.rent = cachedRent;
      this.calculateRentMetrics();
      this.dataLoaded = true;
      this.loading = false;
    } else {
      this.loading = true;
    }
    
    if (cachedAging.length > 0) {
      this.aging = cachedAging;
      this.calculateAgingMetrics();
    }
    
    // Subscribe to updates (will get cached or new data)
    this.dataService.getRentRoll().subscribe({
      next: (d) => {
        if (d && d.length > 0) {
          this.rent = d;
          this.calculateRentMetrics();
          this.dataLoaded = true;
          this.loading = false;
        }
      }
    });
    
    this.dataService.getAging().subscribe({
      next: (d) => {
        if (d && d.length > 0) {
          this.aging = d;
          this.calculateAgingMetrics();
        }
      }
    });
  }
  
  calculateRentMetrics() {
    this.totalCharges = this.rent.reduce((sum, r) => {
      const val = parseFloat(r.monthly_charges?.replace('$', '') || '0');
      return sum + (isNaN(val) ? 0 : val);
    }, 0);
    
    this.totalPayments = this.rent.reduce((sum, r) => {
      const val = parseFloat(r.monthly_payments?.replace('$', '') || '0');
      return sum + (isNaN(val) ? 0 : val);
    }, 0);
    
    this.totalBalance = this.totalCharges - this.totalPayments;
  }
  
  calculateAgingMetrics() {
    this.totalAging = this.aging.reduce((sum, a) => {
      const val = parseFloat(a.total_due?.replace('$', '') || '0');
      return sum + (isNaN(val) ? 0 : val);
    }, 0);
    
    this.overdueCount = this.aging.filter(a => {
      const val = parseFloat(a.total_due?.replace('$', '') || '0');
      return val > 0;
    }).length;
  }
  
  formatCurrency(value: string | number): string {
    if (typeof value === 'string') {
      return value;
    }
    return '$' + value.toFixed(2);
  }
  
  getBalanceClass(balance: string): string {
    const val = parseFloat(balance?.replace('$', '') || '0');
    if (val > 0) return 'negative';
    if (val < 0) return 'positive';
    return '';
  }
  
  getAgingClass(bucket: string): string {
    const val = parseFloat(bucket?.replace('$', '') || '0');
    if (val > 0) return 'overdue';
    return '';
  }
}

