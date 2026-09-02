import { SportStore } from './SportStore'
import { RecordPrefillPayload } from '../models/RecordPrefillPayload'

export class SportDetailNav {
  static open(recordId: string): void {
    AppStorage.setOrCreate('sportDetailId', recordId)
    AppStorage.setOrCreate('challengeDetailId', '')
    AppStorage.setOrCreate('planDetailId', '')
    AppStorage.setOrCreate('showCalendar', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showMonthlyReport', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openChallenge(challengeId: string): void {
    AppStorage.setOrCreate('challengeDetailId', challengeId)
    AppStorage.setOrCreate('sportDetailId', '')
    AppStorage.setOrCreate('planDetailId', '')
    AppStorage.setOrCreate('showCalendar', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showMonthlyReport', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openPlan(planId: string): void {
    AppStorage.setOrCreate('planDetailId', planId)
    AppStorage.setOrCreate('sportDetailId', '')
    AppStorage.setOrCreate('challengeDetailId', '')
    AppStorage.setOrCreate('showCalendar', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showMonthlyReport', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openCalendar(): void {
    AppStorage.setOrCreate('showCalendar', true)
    AppStorage.setOrCreate('sportDetailId', '')
    AppStorage.setOrCreate('challengeDetailId', '')
    AppStorage.setOrCreate('planDetailId', '')
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showMonthlyReport', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openDiagnose(): void {
    AppStorage.setOrCreate('showDiagnose', true)
    AppStorage.setOrCreate('sportDetailId', '')
    AppStorage.setOrCreate('challengeDetailId', '')
    AppStorage.setOrCreate('planDetailId', '')
    AppStorage.setOrCreate('showCalendar', false)
    AppStorage.setOrCreate('showMonthlyReport', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openMonthlyReport(): void {
    AppStorage.setOrCreate('showMonthlyReport', true)
    AppStorage.setOrCreate('sportDetailId', '')
    AppStorage.setOrCreate('challengeDetailId', '')
    AppStorage.setOrCreate('planDetailId', '')
    AppStorage.setOrCreate('showCalendar', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openFavorites(): void {
    AppStorage.setOrCreate('showFavorites', true)
    AppStorage.setOrCreate('sportDetailId', '')
    AppStorage.setOrCreate('challengeDetailId', '')
    AppStorage.setOrCreate('planDetailId', '')
    AppStorage.setOrCreate('showCalendar', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showMonthlyReport', false)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  /** 从日历等入口补记：预填日期 + 打开训练 Tab 表单 */
  static queueRecordForDate(dateKey: string, templateCategory: string = ''): void {
    AppStorage.setOrCreate('recordPrefillDate', dateKey)
    AppStorage.setOrCreate('recordPrefillCategory', templateCategory)
    AppStorage.setOrCreate('recordFormRequest', (AppStorage.get<number>('recordFormRequest') ?? 0) + 1)
  }

  /** 问卷报告「去记一笔」：预填模板类别 */
  static queueRecordFromDiagnose(category: string): void {
    AppStorage.setOrCreate('recordPrefillDate', '')
    AppStorage.setOrCreate('recordPrefillCategory', category)
    AppStorage.setOrCreate('recordFormRequest', (AppStorage.get<number>('recordFormRequest') ?? 0) + 1)
  }

  static consumeRecordPrefill(): RecordPrefillPayload {
    const payload = new RecordPrefillPayload()
    const dateRaw = AppStorage.get<string>('recordPrefillDate')
    const catRaw = AppStorage.get<string>('recordPrefillCategory')
    payload.dateKey = dateRaw !== undefined ? dateRaw : ''
    payload.templateCategory = catRaw !== undefined ? catRaw : ''
    AppStorage.setOrCreate('recordPrefillDate', '')
    AppStorage.setOrCreate('recordPrefillCategory', '')
    return payload
  }

  static close(): void {
    AppStorage.setOrCreate('sportDetailId', '')
    AppStorage.setOrCreate('challengeDetailId', '')
    AppStorage.setOrCreate('planDetailId', '')
    AppStorage.setOrCreate('showCalendar', false)
    AppStorage.setOrCreate('showDiagnose', false)
    AppStorage.setOrCreate('showMonthlyReport', false)
    AppStorage.setOrCreate('showFavorites', false)
    AppStorage.setOrCreate('tabBarHidden', false)
    SportStore.notifyDataChanged()
  }

  static currentId(): string {
    const v = AppStorage.get<string>('sportDetailId')
    return v !== undefined ? v : ''
  }
}
