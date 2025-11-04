import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class ApiService {
  // Use relative path for production (nginx proxy) or absolute for development
  base = window.location.origin === 'http://localhost:4200' 
    ? 'http://localhost:8000' 
    : '/api';
  constructor(private http: HttpClient) {}
  rentRoll() { return this.http.get<any[]>(`${this.base}/rent-roll`); }
  aging() { return this.http.get<any[]>(`${this.base}/ar-aging`); }
  tenantAnalysis() { 
    const url = this.base === '/api' ? `${this.base}/tenant-analysis` : `${this.base}/api/tenant-analysis`;
    return this.http.get<any>(url); 
  }
  financialInsights() { 
    const url = this.base === '/api' ? `${this.base}/financial-insights` : `${this.base}/api/financial-insights`;
    return this.http.get<any>(url); 
  }
  propertyMetrics() { 
    const url = this.base === '/api' ? `${this.base}/property-metrics` : `${this.base}/api/property-metrics`;
    return this.http.get<any>(url); 
  }
  leaseDetails() { 
    const url = this.base === '/api' ? `${this.base}/lease-details` : `${this.base}/api/lease-details`;
    return this.http.get<any[]>(url); 
  }
}

