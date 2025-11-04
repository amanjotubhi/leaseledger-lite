import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, of, timer } from 'rxjs';
import { shareReplay, switchMap, tap, catchError } from 'rxjs/operators';
import { ApiService } from './api.service';

@Injectable({ providedIn: 'root' })
export class DataService {
  // Shared state subjects (public for immediate access)
  public rentRollSubject = new BehaviorSubject<any[]>([]);
  public agingSubject = new BehaviorSubject<any[]>([]);
  public tenantAnalysisSubject = new BehaviorSubject<any>(null);
  public financialInsightsSubject = new BehaviorSubject<any>(null);
  public propertyMetricsSubject = new BehaviorSubject<any>(null);
  
  // Cache observables with shareReplay
  private rentRoll$: Observable<any[]>;
  private aging$: Observable<any[]>;
  private tenantAnalysis$: Observable<any>;
  private financialInsights$: Observable<any>;
  private propertyMetrics$: Observable<any>;
  
  // Loading states
  private loadingStates = {
    rentRoll: false,
    aging: false,
    tenantAnalysis: false,
    financialInsights: false,
    propertyMetrics: false
  };
  
  constructor(private api: ApiService) {
    // Initialize cached observables
    this.rentRoll$ = this.rentRollSubject.asObservable().pipe(shareReplay(1));
    this.aging$ = this.agingSubject.asObservable().pipe(shareReplay(1));
    this.tenantAnalysis$ = this.tenantAnalysisSubject.asObservable().pipe(shareReplay(1));
    this.financialInsights$ = this.financialInsightsSubject.asObservable().pipe(shareReplay(1));
    this.propertyMetrics$ = this.propertyMetricsSubject.asObservable().pipe(shareReplay(1));
    
    // Preload critical data
    this.loadInitialData();
  }
  
  private loadInitialData() {
    // Load dashboard data immediately
    this.refreshRentRoll();
    this.refreshAging();
  }
  
  // Rent Roll
  getRentRoll(): Observable<any[]> {
    // Refresh if empty
    if (this.rentRollSubject.value.length === 0 && !this.loadingStates.rentRoll) {
      this.refreshRentRoll();
    }
    return this.rentRoll$;
  }
  
  refreshRentRoll(): void {
    if (this.loadingStates.rentRoll) return;
    this.loadingStates.rentRoll = true;
    this.api.rentRoll().pipe(
      tap(data => {
        this.rentRollSubject.next(data);
        this.loadingStates.rentRoll = false;
      }),
      catchError(() => {
        this.loadingStates.rentRoll = false;
        return of([]);
      })
    ).subscribe();
  }
  
  // Aging
  getAging(): Observable<any[]> {
    if (this.agingSubject.value.length === 0 && !this.loadingStates.aging) {
      this.refreshAging();
    }
    return this.aging$;
  }
  
  refreshAging(): void {
    if (this.loadingStates.aging) return;
    this.loadingStates.aging = true;
    this.api.aging().pipe(
      tap(data => {
        this.agingSubject.next(data);
        this.loadingStates.aging = false;
      }),
      catchError(() => {
        this.loadingStates.aging = false;
        return of([]);
      })
    ).subscribe();
  }
  
  // Tenant Analysis
  getTenantAnalysis(): Observable<any> {
    if (this.tenantAnalysisSubject.value === null && !this.loadingStates.tenantAnalysis) {
      this.refreshTenantAnalysis();
    }
    return this.tenantAnalysis$;
  }
  
  refreshTenantAnalysis(): void {
    if (this.loadingStates.tenantAnalysis) return;
    this.loadingStates.tenantAnalysis = true;
    this.api.tenantAnalysis().pipe(
      tap(data => {
        this.tenantAnalysisSubject.next(data);
        this.loadingStates.tenantAnalysis = false;
      }),
      catchError(() => {
        this.loadingStates.tenantAnalysis = false;
        return of(null);
      })
    ).subscribe();
  }
  
  // Financial Insights
  getFinancialInsights(): Observable<any> {
    if (this.financialInsightsSubject.value === null && !this.loadingStates.financialInsights) {
      this.refreshFinancialInsights();
    }
    return this.financialInsights$;
  }
  
  refreshFinancialInsights(): void {
    if (this.loadingStates.financialInsights) return;
    this.loadingStates.financialInsights = true;
    this.api.financialInsights().pipe(
      tap(data => {
        this.financialInsightsSubject.next(data);
        this.loadingStates.financialInsights = false;
      }),
      catchError(() => {
        this.loadingStates.financialInsights = false;
        return of(null);
      })
    ).subscribe();
  }
  
  // Property Metrics
  getPropertyMetrics(): Observable<any> {
    if (this.propertyMetricsSubject.value === null && !this.loadingStates.propertyMetrics) {
      this.refreshPropertyMetrics();
    }
    return this.propertyMetrics$;
  }
  
  refreshPropertyMetrics(): void {
    if (this.loadingStates.propertyMetrics) return;
    this.loadingStates.propertyMetrics = true;
    this.api.propertyMetrics().pipe(
      tap(data => {
        this.propertyMetricsSubject.next(data);
        this.loadingStates.propertyMetrics = false;
      }),
      catchError(() => {
        this.loadingStates.propertyMetrics = false;
        return of(null);
      })
    ).subscribe();
  }
  
  // Refresh all data
  refreshAll(): void {
    this.refreshRentRoll();
    this.refreshAging();
    this.refreshTenantAnalysis();
    this.refreshFinancialInsights();
    this.refreshPropertyMetrics();
  }
  
  // Check if data is loading
  isLoading(type: string): boolean {
    return this.loadingStates[type as keyof typeof this.loadingStates] || false;
  }
}

