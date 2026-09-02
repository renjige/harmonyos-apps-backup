/** 文墨集内容分类 */
export class QuoteCategories {
  static all(): string[] {
    const list: string[] = []
    list.push('经史子集')
    list.push('诗词歌赋')
    list.push('书法艺术')
    list.push('传统节气')
    list.push('处世智慧')
    list.push('修身养性')
    return list
  }
}
