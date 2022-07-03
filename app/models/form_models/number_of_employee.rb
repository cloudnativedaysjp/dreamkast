class FormModels::NumberOfEmployee < ActiveHash::Base
  self.data = [
    { id: 1, name: '1～9名' },
    { id: 2, name: '10～49名' },
    { id: 3, name: '50～99名' },
    { id: 4, name: '100～299名' },
    { id: 5, name: '300～499名' },
    { id: 6, name: '500～999名' },
    { id: 7, name: '1,000～1,999名' },
    { id: 8, name: '2,000～4,999名' },
    { id: 9, name: '5,000～9,999名' },
    { id: 10, name: '10,000名以上' },
    { id: 11, name: '非会社組織（NPOなど）' },
    { id: 12, name: '該当なし' }
  ]
end
