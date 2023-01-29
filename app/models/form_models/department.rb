class FormModels::Department < ActiveHash::Base
  self.data = [
    { id: 1, name: '選択してください'},
    { id: 2, name: '経営全般'},
    { id: 3, name: '経営企画'},
    { id: 4, name: '～情報システム～'},
    { id: 5, name: '情報システム部門（社内対応）'},
    { id: 6, name: '情報システム部門（社外対応）'},
    { id: 7, name: '情報システム部門（Webサイト関連）'},
    { id: 8, name: '上記以外の情報システム'},
    { id: 9, name: '～マーケティング～'},
    { id: 10, name: 'デジタル/Webマーケティング'},
    { id: 11, name: '市場調査/リサーチ'},
    { id: 12, name: '上記以外のマーケティング'},
    { id: 13, name: '宣伝/広報'},
    { id: 14, name: '～営業～'},
    { id: 15, name: '営業'},
    { id: 16, name: '該当なし'},
  ]
end
