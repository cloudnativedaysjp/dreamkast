class FormModels::Position < ActiveHash::Base
  self.data = [
    { id: 1, name: '選択してください。'},
    { id: 2, name: '経営クラス'},
    { id: 3, name: '～役員クラス～'},
    { id: 4, name: 'CIO'},
    { id: 5, name: 'CMO'},
    { id: 6, name: 'CTO'},
    { id: 7, name: 'その他/役員'},
    { id: 8, name: '本部長/事業部長クラス'},
    { id: 9, name: '部長/次長クラス'},
    { id: 10, name: '課長クラス'},
    { id: 11, name: '係長/主任クラス'},
    { id: 12, name: '一般職'},
    { id: 13, name: '専門職'},
    { id: 14, name: '学生'},
    { id: 15, name: '無職'},
    { id: 16, name: '該当なし'},
  ]
end
