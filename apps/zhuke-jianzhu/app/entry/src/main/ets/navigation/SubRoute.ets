/** 子页面路由 */
export class SubRoute {
  static readonly none: string = ''
  static readonly projectDetail: string = 'projectDetail'
  static readonly safetyDetail: string = 'safetyDetail'
  static readonly profile: string = 'profile'
  static readonly settings: string = 'settings'
  static readonly help: string = 'help'
  static readonly feedback: string = 'feedback'
  static readonly about: string = 'about'
  static readonly legalPrivacy: string = 'legalPrivacy'
  static readonly legalAgreement: string = 'legalAgreement'
}

export class ProjectPayload {
  id: string = ''
  name: string = ''
  statusCode: string = 'planned'
}
