/**
 * @jest-environment jsdom
 */

const { countChars, MAX_TITLE_CHARS, MAX_ABSTRACT_CHARS } = require('../speaker_form.js');

describe('speaker_form.js', () => {
  describe('countChars', () => {
    describe('通常の文字列', () => {
      it('空文字列は0を返す', () => {
        expect(countChars('')).toBe(0);
        expect(countChars(null)).toBe(0);
        expect(countChars(undefined)).toBe(0);
      });

      it('半角文字を正しくカウントする', () => {
        expect(countChars('a')).toBe(1);
        expect(countChars('abc')).toBe(3);
        expect(countChars('a'.repeat(60))).toBe(60);
        expect(countChars('a'.repeat(61))).toBe(61);
      });

      it('全角文字を正しくカウントする', () => {
        expect(countChars('あ')).toBe(1);
        expect(countChars('あいうえお')).toBe(5);
        expect(countChars('あ'.repeat(60))).toBe(60);
        expect(countChars('あ'.repeat(61))).toBe(61);
      });

      it('全角・半角混在の文字列を正しくカウントする', () => {
        expect(countChars('あa')).toBe(2);
        expect(countChars('あ'.repeat(30) + 'a'.repeat(30))).toBe(60);
        expect(countChars('あ'.repeat(30) + 'a'.repeat(31))).toBe(61);
      });
    });

    describe('絵文字', () => {
      it('基本的な絵文字を1文字としてカウントする', () => {
        expect(countChars('😀')).toBe(1);
        expect(countChars('😀😀😀')).toBe(3);
        expect(countChars('😀'.repeat(60))).toBe(60);
        expect(countChars('😀'.repeat(61))).toBe(61);
      });

      it('複合絵文字（ゼロ幅結合子を含む）を1文字としてカウントする', () => {
        // 👨‍👩‍👧‍👦 は複数のコードポイントで構成されるが、1文字としてカウントされるべき
        const familyEmoji = '👨‍👩‍👧‍👦';
        expect(countChars(familyEmoji)).toBe(1);
        expect(countChars(familyEmoji.repeat(30))).toBe(30);
        expect(countChars(familyEmoji.repeat(60))).toBe(60);
      });

      it('様々な絵文字を1文字としてカウントする', () => {
        const emojis = ['😀', '🎉', '🚀', '❤️', '👍', '🌟'];
        emojis.forEach(emoji => {
          expect(countChars(emoji)).toBe(1);
        });
        expect(countChars(emojis.join(''))).toBe(emojis.length);
      });

      it('絵文字と通常文字の混在を正しくカウントする', () => {
        expect(countChars('😀あ')).toBe(2);
        expect(countChars('😀a')).toBe(2);
        expect(countChars('😀'.repeat(30) + 'あ'.repeat(30))).toBe(60);
        expect(countChars('😀'.repeat(30) + 'a'.repeat(30))).toBe(60);
      });
    });

    describe('文字数制限の定数', () => {
      it('MAX_TITLE_CHARSが60である', () => {
        expect(MAX_TITLE_CHARS).toBe(60);
      });

      it('MAX_ABSTRACT_CHARSが500である', () => {
        expect(MAX_ABSTRACT_CHARS).toBe(500);
      });
    });

    describe('エッジケース', () => {
      it('改行文字を含む文字列を正しくカウントする', () => {
        expect(countChars('あ\nい')).toBe(3); // 改行も1文字としてカウント
        expect(countChars('a\nb')).toBe(3);
      });

      it('タブ文字を含む文字列を正しくカウントする', () => {
        expect(countChars('あ\tい')).toBe(3);
        expect(countChars('a\tb')).toBe(3);
      });

      it('空白文字を含む文字列を正しくカウントする', () => {
        expect(countChars('あ い')).toBe(3);
        expect(countChars('a b')).toBe(3);
      });

      it('特殊文字を含む文字列を正しくカウントする', () => {
        expect(countChars('あ!い')).toBe(3);
        expect(countChars('a!b')).toBe(3);
        expect(countChars('あ@い')).toBe(3);
        expect(countChars('a@b')).toBe(3);
      });
    });

    describe('実際の使用ケース', () => {
      it('タイトルが60文字ちょうどの場合', () => {
        const title = 'あ'.repeat(60);
        expect(countChars(title)).toBe(60);
        expect(countChars(title) <= MAX_TITLE_CHARS).toBe(true);
      });

      it('タイトルが61文字の場合', () => {
        const title = 'あ'.repeat(61);
        expect(countChars(title)).toBe(61);
        expect(countChars(title) > MAX_TITLE_CHARS).toBe(true);
      });

      it('概要が500文字ちょうどの場合', () => {
        const abstract = 'あ'.repeat(500);
        expect(countChars(abstract)).toBe(500);
        expect(countChars(abstract) <= MAX_ABSTRACT_CHARS).toBe(true);
      });

      it('概要が501文字の場合', () => {
        const abstract = 'あ'.repeat(501);
        expect(countChars(abstract)).toBe(501);
        expect(countChars(abstract) > MAX_ABSTRACT_CHARS).toBe(true);
      });

      it('絵文字を含むタイトルが60文字の場合', () => {
        const title = '😀'.repeat(60);
        expect(countChars(title)).toBe(60);
        expect(countChars(title) <= MAX_TITLE_CHARS).toBe(true);
      });

      it('絵文字を含む概要が500文字の場合', () => {
        const abstract = '😀'.repeat(500);
        expect(countChars(abstract)).toBe(500);
        expect(countChars(abstract) <= MAX_ABSTRACT_CHARS).toBe(true);
      });
    });
  });
});
