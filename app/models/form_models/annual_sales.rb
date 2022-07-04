class FormModels::AnnualSales < ActiveHash::Base
  self.data = [
    { id: 1, name: '5,000万円未満' },
    { id: 2, name: '5,000万円～1億円未満' },
    { id: 3, name: '1億円～10億円未満' },
    { id: 4, name: '10億円～50億円' },
    { id: 5, name: '50億円～100億円' },
    { id: 6, name: '100億円～500億円' },
    { id: 7, name: '500億円～1,000億円' },
    { id: 8, name: '1,000億円～5,000億円' },
    { id: 9, name: '5,000億円～1兆円' },
    { id: 10, name: '1兆円～' },
    { id: 11, name: '該当なし' }
  ]
end
