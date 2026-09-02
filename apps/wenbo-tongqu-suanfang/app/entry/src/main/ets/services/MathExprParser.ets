import { CustomExpr } from '../models/MathModels'

export class MathExprParser {
  static parse(raw: string): CustomExpr | null {
    const t = MathExprParser.normalize(raw)
    if (t.length < 3) {
      return null
    }
    let opAt = -1
    let op = ''
    const len = t.length
    for (let i = 1; i < len; i++) {
      const ch = t.charAt(i)
      if (ch === '+' || ch === '-' || ch === '*' || ch === '/') {
        opAt = i
        op = ch
      }
    }
    if (opAt <= 0 || opAt >= len - 1) {
      return null
    }
    const leftN = Number.parseInt(t.substring(0, opAt))
    const rightN = Number.parseInt(t.substring(opAt + 1))
    if (!Number.isFinite(leftN) || !Number.isFinite(rightN)) {
      return null
    }
    if (leftN < 0 || rightN < 0 || leftN > 999 || rightN > 999) {
      return null
    }
    const item = new CustomExpr()
    item.left = leftN
    item.right = rightN
    if (op === '+') {
      item.op = 'add'
      item.answer = leftN + rightN
      item.expression = `${leftN} + ${rightN} = ?`
    } else if (op === '-') {
      if (leftN < rightN) {
        return null
      }
      item.op = 'sub'
      item.answer = leftN - rightN
      item.expression = `${leftN} − ${rightN} = ?`
    } else if (op === '*') {
      item.op = 'mul'
      item.answer = leftN * rightN
      item.expression = `${leftN} × ${rightN} = ?`
    } else {
      if (rightN === 0 || leftN % rightN !== 0) {
        return null
      }
      item.op = 'div'
      item.answer = leftN / rightN
      item.expression = `${leftN} ÷ ${rightN} = ?`
    }
    return item
  }

  private static normalize(raw: string): string {
    let t = raw.trim()
    t = t.split('×').join('*')
    t = t.split('x').join('*')
    t = t.split('X').join('*')
    t = t.split('÷').join('/')
    t = t.split('−').join('-')
    t = t.split(' ').join('')
    t = t.split('＝').join('')
    t = t.split('=').join('')
    t = t.split('?').join('')
    return t
  }
}
